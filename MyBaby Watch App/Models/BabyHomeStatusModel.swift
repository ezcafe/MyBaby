import Foundation
import Observation
import WidgetKit

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

/// Which care control last failed a live send (chip fail chrome).
enum CareFailedControl: Equatable {
    case timed(TimedChipSide)
    case bottle(ml: Int)
    case pump(ml: Int)
    case diaper(DiaperKind)
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
    var lastFailedControl: CareFailedControl?
    /// Gear sheet (Settings Option B) — not a TabView page.
    var showSettingsSheet: Bool = false
    var isStatusLoading: Bool = false

    /// Latest done-flash clear work — cancelled when a newer flash schedules.
    private(set) var clearDoneTask: Task<Void, Never>?

    /// Injected live client (nil in sample / previews).
    var graphQLClient: (any BabyGraphQLClienting)?

    /// Last quick-care id for retry tests / unknown failure.
    private(set) var lastClientRequestId: String?

    /// Payload for footer Retry after a failed send.
    private(set) var lastRetryAction: [String: Any]?
    private(set) var lastRetryBreastRunning: [String: Any]?
    private(set) var lastRetryClientRequestId: String?

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
        lastFailedControl = nil
        clearRetryPayload()
    }

    func useLive(client: any BabyGraphQLClienting) {
        mode = .live
        graphQLClient = client
        isConnected = true
        needsReconnect = false
        statusFail = nil
        lastFailedControl = nil
        clearRetryPayload()
    }

    /// Clear Keychain token and leave care until user Connects again.
    func logout(tokenStore: any BabyAPITokenStoring = BabyAPITokenStore()) {
        try? tokenStore.clear()
        graphQLClient = nil
        mode = .sample
        isConnected = false
        needsReconnect = false
        statusFail = nil
        lastFailedControl = nil
        showSettingsSheet = false
        clearRetryPayload()
    }

    func isFailed(_ control: CareFailedControl) -> Bool {
        lastFailedControl == control
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
        lastFailedControl = nil
        BabyHaptics.save()
        scheduleClearDone { self.bottleDoneMl = nil }
        if mode == .live {
            Task { await sendQuickCare(action: ["kind": "FORMULA", "amountMl": ml], control: .bottle(ml: ml)) }
        }
    }

    func selectPump(ml: Int) {
        applySideEffects(.pumpAmount)
        selectedPumpMl = nil
        pumpDoneMl = ml
        lastFailedControl = nil
        BabyHaptics.save()
        scheduleClearDone { self.pumpDoneMl = nil }
        if mode == .live {
            Task { await sendQuickCare(action: ["kind": "PUMP_AMOUNT", "amountMl": ml], control: .pump(ml: ml)) }
        }
    }

    func selectDiaper(_ kind: DiaperKind, details: DiaperSheetDraft? = nil) {
        applySideEffects(.diaper)
        selectedDiaperKind = nil
        diaperDoneKind = kind
        lastFailedControl = nil
        BabyHaptics.save()
        scheduleClearDone { self.diaperDoneKind = nil }
        if mode == .live {
            let action: [String: Any]
            if let details, kind == .poop || kind == .mixed {
                action = diaperSheetSaveAction(kind: kind, draft: details)
            } else {
                action = [
                    "kind": "DIAPER",
                    "diaperKind": kind.apiValue,
                ]
            }
            Task {
                await sendQuickCare(
                    action: action,
                    control: .diaper(kind)
                )
            }
        }
    }

    func loadLiveStatus() async {
        guard mode == .live, let client = graphQLClient else { return }
        isStatusLoading = true
        defer { isStatusLoading = false }
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
            lastFailedControl = nil
            clearRetryPayload()
            needsReconnect = false
            persistStatusForWidgets()
        } catch {
            applyLiveFailure(error)
        }
    }

    /// Write App Group snapshot for complications (never includes token).
    func persistStatusForWidgets() {
        BabyCareStatusStore.save(snapshot: snapshot)
        WidgetCenter.shared.reloadTimelines(ofKind: "BabyCareComplication")
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
        if BabyHomeDeepLink.isSettingsLink(url) {
            showSettingsSheet = true
            return
        }
        selectedPage = BabyHomeDeepLink.page(from: url)
    }

    /// Footer Retry: re-send last failed quick-care, or reload status when no chip fail.
    func retryLastFailure() async {
        if let action = lastRetryAction, let id = lastRetryClientRequestId {
            await sendQuickCare(
                action: action,
                breastRunning: lastRetryBreastRunning,
                clientRequestId: BabyClientRequestId.retrySame(id),
                control: lastFailedControl
            )
            return
        }
        if statusFail != nil {
            await loadLiveStatus()
        }
    }

    func discardRecovery() {
        pendingRecovery = nil
        statusFail = nil
        lastFailedControl = nil
        clearRetryPayload()
    }

    private func clearRetryPayload() {
        lastRetryAction = nil
        lastRetryBreastRunning = nil
        lastRetryClientRequestId = nil
    }

    private func handleBreastToggle(active: TimedChipSide) {
        let apiSide = active == .breastLeft ? "breast_l" : "breast_r"
        let phase = active == .breastLeft ? breastLeft : breastRight
        switch phase {
        case .idle:
            applySideEffects(.breast)
            lastFailedControl = nil
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
            lastFailedControl = nil
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
                        breastRunning: ["side": apiSide, "durationSec": duration],
                        control: .timed(active)
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
            lastFailedControl = nil
            persistStatusForWidgets()
            if mode == .live {
                Task { await sendQuickCare(action: ["kind": "SLEEP"], control: .timed(.nap)) }
            }
        case .running:
            applySideEffects(.sleep)
            snapshot.openNapStartedAt = nil
            scheduleClearDoneForSide()
            nap = .done
            lastFailedControl = nil
            persistStatusForWidgets()
            if mode == .live {
                Task { await sendQuickCare(action: ["kind": "SLEEP"], control: .timed(.nap)) }
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
            lastFailedControl = nil
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
            lastFailedControl = nil
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
                        breastRunning: ["side": apiSide, "durationSec": duration],
                        control: .timed(side)
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
        clientRequestId: String? = nil,
        control: CareFailedControl? = nil
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
            lastFailedControl = nil
            clearRetryPayload()
            await loadLiveStatus()
        } catch {
            lastRetryAction = action
            lastRetryBreastRunning = breastRunning
            lastRetryClientRequestId = id
            if let control {
                lastFailedControl = control
            }
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
