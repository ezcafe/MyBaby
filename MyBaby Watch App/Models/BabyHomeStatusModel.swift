import Foundation
import Observation

enum TimedChipSide: String, CaseIterable, Identifiable {
    case breastLeft = "Left"
    case breastRight = "Right"
    case nap = "Start nap"
    /// Unique raw ids — display title is `title` (“Left” / “Right”).
    case pumpLeft = "pumpLeft"
    case pumpRight = "pumpRight"
    case pumpBoth = "Both"

    var id: String { rawValue }

    /// Idle / running chip label.
    var title: String {
        switch self {
        case .breastLeft, .pumpLeft: return "Left"
        case .breastRight, .pumpRight: return "Right"
        case .nap: return "Start nap"
        case .pumpBoth: return "Both"
        }
    }

    var idleSubtitle: String { "Tap to start" }

    /// Title while the chip is running (no “Tap to stop”).
    var runningTitle: String {
        switch self {
        case .nap: return "Nap"
        case .breastLeft, .breastRight, .pumpLeft, .pumpRight, .pumpBoth: return title
        }
    }
}

enum TimedChipPhase: Equatable {
    case idle
    case running(startedAt: Date)
    case done
}

enum CareFooterContent: Equatable {
    case recovery(message: String)
    case statusFail(message: String)
    case tip(message: String)
    case none
}

enum CareFooterResolver {
    /// Priority: recovery → status fail → tip. Never stack tip + recovery.
    static func resolve(
        recovery: String?,
        statusFail: String?,
        tip: String?
    ) -> CareFooterContent {
        if let recovery, !recovery.isEmpty { return .recovery(message: recovery) }
        if let statusFail, !statusFail.isEmpty { return .statusFail(message: statusFail) }
        if let tip, !tip.isEmpty { return .tip(message: tip) }
        return .none
    }
}

@Observable
@MainActor
final class BabyHomeStatusModel {
    var snapshot: BabyHomeStatusSnapshot
    var selectedPage: BabyHomePage = .feed
    var isConnected: Bool = true

    var breastLeft: TimedChipPhase = .idle
    var breastRight: TimedChipPhase = .idle
    var nap: TimedChipPhase = .idle
    var pumpLeft: TimedChipPhase = .idle
    var pumpRight: TimedChipPhase = .idle
    var pumpBoth: TimedChipPhase = .idle

    /// Not used for lasting accent — flash uses done* only (my-apps parity).
    var selectedBottleMl: Int?
    var selectedPumpMl: Int?
    var selectedDiaperKind: DiaperKind?
    var bottleDoneMl: Int?
    var pumpDoneMl: Int?
    var diaperDoneKind: DiaperKind?

    var pendingRecovery: String?
    var statusFail: String?

    init(snapshot: BabyHomeStatusSnapshot = .sampleNextFeed()) {
        self.snapshot = snapshot
        if let start = snapshot.openNapStartedAt {
            nap = .running(startedAt: start)
        }
    }

    var primarySignal: BabyCarePrimaryKind {
        BabyCarePrimarySignal.resolve(snapshot, now: .now)
    }

    private var napOpen: Bool {
        if case .running = nap { return true }
        return snapshot.openNapStartedAt != nil
    }

    private var breastRunning: Bool {
        if case .running = breastLeft { return true }
        if case .running = breastRight { return true }
        return false
    }

    func footer(tip: String) -> CareFooterContent {
        CareFooterResolver.resolve(
            recovery: pendingRecovery,
            statusFail: statusFail,
            tip: tip
        )
    }

    func toggleTimed(_ side: TimedChipSide) {
        switch side {
        case .breastLeft:
            applySideEffects(.breast)
            if case .idle = breastLeft, case .running = breastRight {
                breastRight = .idle
            }
            breastLeft = advance(breastLeft)
        case .breastRight:
            applySideEffects(.breast)
            if case .idle = breastRight, case .running = breastLeft {
                breastLeft = .idle
            }
            breastRight = advance(breastRight)
        case .nap:
            applySideEffects(.sleep)
            nap = advanceNap(nap)
        case .pumpLeft:
            applySideEffects(.pumpTimer)
            clearOtherPumpSides(except: .pumpLeft)
            pumpLeft = advance(pumpLeft)
        case .pumpRight:
            applySideEffects(.pumpTimer)
            clearOtherPumpSides(except: .pumpRight)
            pumpRight = advance(pumpRight)
        case .pumpBoth:
            applySideEffects(.pumpTimer)
            clearOtherPumpSides(except: .pumpBoth)
            pumpBoth = advance(pumpBoth)
        }
        BabyHaptics.timerChanged()
    }

    func selectBottle(ml: Int) {
        applySideEffects(.bottle)
        selectedBottleMl = nil
        bottleDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.bottleDoneMl = nil }
    }

    func selectPump(ml: Int) {
        applySideEffects(.pumpAmount)
        selectedPumpMl = nil
        pumpDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.pumpDoneMl = nil }
    }

    func selectDiaper(_ kind: DiaperKind) {
        applySideEffects(.diaper)
        selectedDiaperKind = nil
        diaperDoneKind = kind
        BabyHaptics.save()
        scheduleClearDone { self.diaperDoneKind = nil }
    }

    func applyDeepLink(_ url: URL) {
        selectedPage = BabyHomeDeepLink.page(from: url)
    }

    private func clearOtherPumpSides(except keep: TimedChipSide) {
        if keep != .pumpLeft, case .running = pumpLeft { pumpLeft = .idle }
        if keep != .pumpRight, case .running = pumpRight { pumpRight = .idle }
        if keep != .pumpBoth, case .running = pumpBoth { pumpBoth = .idle }
    }

    private func applySideEffects(_ action: CareQuickAction) {
        let flags = CareSideEffects.flags(
            for: action,
            napOpen: napOpen,
            breastRunning: breastRunning
        )
        if flags.endOpenNap {
            endOpenNapNow()
        }
        if flags.stopBreast {
            stopBreastNow()
        }
    }

    /// Related-stop from another action: hide active UI (idle), no Done flash.
    private func endOpenNapNow() {
        snapshot.openNapStartedAt = nil
        if case .running = nap {
            nap = .idle
        }
    }

    /// Related-stop from another action: hide active UI (idle), no Done flash.
    private func stopBreastNow() {
        if case .running = breastLeft {
            breastLeft = .idle
        }
        if case .running = breastRight {
            breastRight = .idle
        }
    }

    private func advance(_ phase: TimedChipPhase) -> TimedChipPhase {
        switch phase {
        case .idle:
            return .running(startedAt: .now)
        case .running:
            scheduleClearDoneForSide()
            return .done
        case .done:
            return .idle
        }
    }

    private func advanceNap(_ phase: TimedChipPhase) -> TimedChipPhase {
        switch phase {
        case .idle:
            let started = Date.now
            snapshot.openNapStartedAt = started
            return .running(startedAt: started)
        case .running:
            snapshot.openNapStartedAt = nil
            scheduleClearDoneForSide()
            return .done
        case .done:
            return .idle
        }
    }

    private func scheduleClearDoneForSide() {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            if case .done = breastLeft { breastLeft = .idle }
            if case .done = breastRight { breastRight = .idle }
            if case .done = nap { nap = .idle }
            if case .done = pumpLeft { pumpLeft = .idle }
            if case .done = pumpRight { pumpRight = .idle }
            if case .done = pumpBoth { pumpBoth = .idle }
        }
    }

    private func scheduleClearDone(_ clear: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            clear()
        }
    }
}

enum DiaperKind: String, CaseIterable, Identifiable {
    case wet = "Wet"
    case poop = "Poop"
    case mixed = "Mixed"
    case dry = "Dry"

    var id: String { rawValue }

    /// API later maps Poop → dirty.
    var apiValue: String {
        switch self {
        case .wet: return "wet"
        case .poop: return "dirty"
        case .mixed: return "mixed"
        case .dry: return "dry"
        }
    }

    var systemImage: String {
        switch self {
        case .wet: return "drop.fill"
        case .poop: return "leaf.fill"
        case .mixed: return "circle.lefthalf.filled"
        case .dry: return "sun.max.fill"
        }
    }
}

enum BabyHaptics {
    static func save() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }

    static func timerChanged() {
        #if os(watchOS)
        WKInterfaceDevice.current().play(.click)
        #endif
    }
}

#if os(watchOS)
import WatchKit
#endif
