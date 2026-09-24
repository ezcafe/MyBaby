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

enum CareDataMode: Equatable {
    case sample
    case live
}

@Observable
@MainActor
final class BabyHomeStatusModel {
    var snapshot: BabyHomeStatusSnapshot
    var selectedPage: BabyHomePage = .feed
    var isConnected: Bool = false
    var mode: CareDataMode = .sample
    var needsReconnect: Bool = false

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

    /// Latest done-flash clear work — cancelled when a newer flash schedules.
    private(set) var clearDoneTask: Task<Void, Never>?

    /// Injected live client (nil in sample / previews).
    var graphQLClient: (any BabyGraphQLClienting)?

    /// Last quick-care id for retry tests / unknown failure.
    private(set) var lastClientRequestId: String?

    init(
        snapshot: BabyHomeStatusSnapshot = .sampleNextFeed(),
        isConnected: Bool = false,
        mode: CareDataMode = .sample,
        graphQLClient: (any BabyGraphQLClienting)? = nil
    ) {
        self.snapshot = snapshot
        self.isConnected = isConnected
        self.mode = mode
        self.graphQLClient = graphQLClient
        if let start = snapshot.openNapStartedAt {
            nap = .running(startedAt: start)
        }
    }

    func useSample() {
        mode = .sample
        graphQLClient = nil
        isConnected = true
        needsReconnect = false
        statusFail = nil
    }

    func useLive(client: any BabyGraphQLClienting) {
        mode = .live
        graphQLClient = client
        isConnected = true
        needsReconnect = false
        statusFail = nil
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
            handleBreastToggle(active: .breastLeft)
        case .breastRight:
            handleBreastToggle(active: .breastRight)
        case .nap:
            handleNapToggle()
        case .pumpLeft:
            handlePumpTimerToggle(side: .pumpLeft)
        case .pumpRight:
            handlePumpTimerToggle(side: .pumpRight)
        case .pumpBoth:
            handlePumpTimerToggle(side: .pumpBoth)
        }
        BabyHaptics.timerChanged()
    }

    func selectBottle(ml: Int) {
        applySideEffects(.bottle)
        selectedBottleMl = nil
        bottleDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.bottleDoneMl = nil }
        if mode == .live {
            Task { await sendQuickCare(action: ["kind": "FORMULA", "amountMl": ml]) }
        }
    }

    func selectPump(ml: Int) {
        applySideEffects(.pumpAmount)
        selectedPumpMl = nil
        pumpDoneMl = ml
        BabyHaptics.save()
        scheduleClearDone { self.pumpDoneMl = nil }
        if mode == .live {
            Task { await sendQuickCare(action: ["kind": "PUMP_AMOUNT", "amountMl": ml]) }
        }
    }

    func selectDiaper(_ kind: DiaperKind) {
        applySideEffects(.diaper)
        selectedDiaperKind = nil
        diaperDoneKind = kind
        BabyHaptics.save()
        scheduleClearDone { self.diaperDoneKind = nil }
        if mode == .live {
            Task {
                await sendQuickCare(action: [
                    "kind": "DIAPER",
                    "diaperKind": kind.apiValue,
                ])
            }
        }
    }

    func loadLiveStatus() async {
        guard mode == .live, let client = graphQLClient else { return }
        let window = BabyLocalDayWindow.make()
        do {
            let vars = try JSONSerialization.data(withJSONObject: [
                "dayFrom": window.dayFrom,
                "dayTo": window.dayTo,
            ])
            let data = try await client.execute(
                document: BabyGraphQLDocuments.homeQuickStatus,
                variablesJSON: vars
            )
            let payload = try BabyHomeStatusMapper.decodeStatusData(data)
            snapshot = BabyHomeStatusMapper.map(payload)
            if let start = snapshot.openNapStartedAt {
                nap = .running(startedAt: start)
            } else if case .running = nap {
                nap = .idle
            }
            statusFail = nil
            needsReconnect = false
        } catch {
            applyLiveFailure(error)
        }
    }

    /// Unknown-failure retry: reuse the same clientRequestId.
    func retryQuickCare(
        action: [String: Any],
        breastRunning: [String: Any]? = nil,
        clientRequestId: String
    ) async {
        await sendQuickCare(
            action: action,
            breastRunning: breastRunning,
            clientRequestId: BabyClientRequestId.retrySame(clientRequestId)
        )
    }

    func applyDeepLink(_ url: URL) {
        selectedPage = BabyHomeDeepLink.page(from: url)
    }

    private func handleBreastToggle(active: TimedChipSide) {
        let apiSide = active == .breastLeft ? "breast_l" : "breast_r"
        let phase = active == .breastLeft ? breastLeft : breastRight
        switch phase {
        case .idle:
            applySideEffects(.breast)
            if active == .breastLeft {
                if case .running = breastRight { breastRight = .idle }
                breastLeft = .running(startedAt: .now)
            } else {
                if case .running = breastLeft { breastLeft = .idle }
                breastRight = .running(startedAt: .now)
            }
        case .running(let startedAt):
            let duration = max(Int(Date.now.timeIntervalSince(startedAt)), 1)
            applySideEffects(.breast)
            scheduleClearDoneForSide()
            if active == .breastLeft {
                breastLeft = .done
            } else {
                breastRight = .done
            }
            if mode == .live {
                Task {
                    await sendQuickCare(
                        action: ["kind": "BREAST", "side": apiSide],
                        breastRunning: ["side": apiSide, "durationSec": duration]
                    )
                }
            }
        case .done:
            if active == .breastLeft {
                breastLeft = .idle
            } else {
                breastRight = .idle
            }
        }
    }

    private func handleNapToggle() {
        switch nap {
        case .idle:
            applySideEffects(.sleep)
            let started = Date.now
            snapshot.openNapStartedAt = started
            nap = .running(startedAt: started)
            if mode == .live {
                Task { await sendQuickCare(action: ["kind": "SLEEP"]) }
            }
        case .running:
            applySideEffects(.sleep)
            snapshot.openNapStartedAt = nil
            scheduleClearDoneForSide()
            nap = .done
            if mode == .live {
                Task { await sendQuickCare(action: ["kind": "SLEEP"]) }
            }
        case .done:
            nap = .idle
        }
    }

    private func handlePumpTimerToggle(side: TimedChipSide) {
        let apiSide: String = {
            switch side {
            case .pumpLeft: return "pump_l"
            case .pumpRight: return "pump_r"
            case .pumpBoth: return "pump_both"
            default: return "pump_l"
            }
        }()
        let phase: TimedChipPhase = {
            switch side {
            case .pumpLeft: return pumpLeft
            case .pumpRight: return pumpRight
            case .pumpBoth: return pumpBoth
            default: return .idle
            }
        }()
        switch phase {
        case .idle:
            applySideEffects(.pumpTimer)
            clearOtherPumpSides(except: side)
            let running = TimedChipPhase.running(startedAt: .now)
            switch side {
            case .pumpLeft: pumpLeft = running
            case .pumpRight: pumpRight = running
            case .pumpBoth: pumpBoth = running
            default: break
            }
        case .running(let startedAt):
            let duration = max(Int(Date.now.timeIntervalSince(startedAt)), 1)
            applySideEffects(.pumpTimer)
            scheduleClearDoneForSide()
            switch side {
            case .pumpLeft: pumpLeft = .done
            case .pumpRight: pumpRight = .done
            case .pumpBoth: pumpBoth = .done
            default: break
            }
            if mode == .live {
                Task {
                    await sendQuickCare(
                        action: ["kind": "BREAST", "side": apiSide],
                        breastRunning: ["side": apiSide, "durationSec": duration]
                    )
                }
            }
        case .done:
            switch side {
            case .pumpLeft: pumpLeft = .idle
            case .pumpRight: pumpRight = .idle
            case .pumpBoth: pumpBoth = .idle
            default: break
            }
        }
    }

    private func sendQuickCare(
        action: [String: Any],
        breastRunning: [String: Any]? = nil,
        clientRequestId: String? = nil
    ) async {
        guard mode == .live, let client = graphQLClient else { return }
        let id = clientRequestId ?? BabyClientRequestId.make()
        lastClientRequestId = id
        var input: [String: Any] = [
            "action": action,
            "clientRequestId": id,
        ]
        if let breastRunning {
            input["breastRunning"] = breastRunning
        }
        do {
            let vars = try JSONSerialization.data(withJSONObject: ["input": input])
            _ = try await client.execute(
                document: BabyGraphQLDocuments.quickCare,
                variablesJSON: vars
            )
            await loadLiveStatus()
        } catch {
            applyLiveFailure(error)
        }
    }

    private func applyLiveFailure(_ error: Error) {
        if let gql = error as? BabyGraphQLError {
            switch gql {
            case .graphQL(_, let code) where code == "UNAUTHORIZED" || code == "FORBIDDEN":
                statusFail = "Unauthorized — reconnect"
                needsReconnect = true
            case .httpStatus(401), .httpStatus(403):
                statusFail = "Unauthorized — reconnect"
                needsReconnect = true
            case .missingToken:
                statusFail = "Missing API token"
                needsReconnect = true
            case .badURL:
                statusFail = "Bad API URL"
            case .graphQL(let message, _):
                statusFail = message
            case .httpStatus(let code):
                statusFail = "HTTP \(code)"
            case .decoding, .transport:
                statusFail = "Network error — retry"
            }
        } else {
            statusFail = "Network error — retry"
        }
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

    private func scheduleClearDoneForSide() {
        scheduleClearDone {
            if case .done = self.breastLeft { self.breastLeft = .idle }
            if case .done = self.breastRight { self.breastRight = .idle }
            if case .done = self.nap { self.nap = .idle }
            if case .done = self.pumpLeft { self.pumpLeft = .idle }
            if case .done = self.pumpRight { self.pumpRight = .idle }
            if case .done = self.pumpBoth { self.pumpBoth = .idle }
        }
    }

    private func scheduleClearDone(_ clear: @escaping @MainActor () -> Void) {
        clearDoneTask?.cancel()
        clearDoneTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
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
