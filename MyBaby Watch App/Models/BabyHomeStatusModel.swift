import Foundation
import Observation

enum TimedChipSide: String, CaseIterable, Identifiable {
    case breastLeft = "Left"
    case breastRight = "Right"
    case nap = "Start nap"
    case pumpLeft = "Pump L"
    case pumpRight = "Pump R"

    var id: String { rawValue }

    var idleSubtitle: String { "Tap to start" }
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
    var selectedPage: BabyHomePage = .feedBottle
    var isConnected: Bool = true

    var breastLeft: TimedChipPhase = .idle
    var breastRight: TimedChipPhase = .idle
    var nap: TimedChipPhase = .idle
    var pumpLeft: TimedChipPhase = .idle
    var pumpRight: TimedChipPhase = .idle

    var selectedBottleMl: Int?
    var selectedPumpMl: Int?
    var selectedDiaperKind: DiaperKind?
    var bottleDoneMl: Int?
    var pumpDoneMl: Int?
    var diaperDoneKind: DiaperKind?

    var pendingRecovery: String?
    var statusFail: String?

    var now: Date = .now

    init(snapshot: BabyHomeStatusSnapshot = .sampleNextFeed()) {
        self.snapshot = snapshot
        if let start = snapshot.openNapStartedAt {
            nap = .running(startedAt: start)
        }
    }

    var primarySignal: BabyCarePrimaryKind {
        BabyCarePrimarySignal.resolve(snapshot, now: now)
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
        case .breastLeft: breastLeft = advance(breastLeft)
        case .breastRight: breastRight = advance(breastRight)
        case .nap: nap = advanceNap(nap)
        case .pumpLeft: pumpLeft = advance(pumpLeft)
        case .pumpRight: pumpRight = advance(pumpRight)
        }
        BabyHaptics.timerChanged()
    }

    func selectBottle(ml: Int) {
        selectedBottleMl = ml
        bottleDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.bottleDoneMl = nil }
    }

    func selectPump(ml: Int) {
        selectedPumpMl = ml
        pumpDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.pumpDoneMl = nil }
    }

    func selectDiaper(_ kind: DiaperKind) {
        selectedDiaperKind = kind
        diaperDoneKind = kind
        BabyHaptics.save()
        scheduleClearDone { self.diaperDoneKind = nil }
    }

    func applyDeepLink(_ url: URL) {
        selectedPage = BabyHomeDeepLink.page(from: url)
    }

    private func advance(_ phase: TimedChipPhase) -> TimedChipPhase {
        switch phase {
        case .idle:
            return .running(startedAt: now)
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
            snapshot.openNapStartedAt = now
            return .running(startedAt: now)
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
