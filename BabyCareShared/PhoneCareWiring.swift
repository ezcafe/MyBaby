import Foundation

/// Maps Phone session clients into the shared care model (live / offline / sample).
enum PhoneCareWiring {
    /// Fresh model mirrored from the current session (does not start network).
    @MainActor
    static func makeModel(from session: PhoneSessionModel) -> BabyHomeStatusModel {
        let model = BabyHomeStatusModel(
            snapshot: .sampleNextFeed(),
            isConnected: session.isConnected,
            mode: session.mode,
            graphQLClient: session.graphQLClient
        )
        apply(session: session, to: model)
        return model
    }

    /// Keep care model mode + clients aligned with Phone session.
    @MainActor
    static func apply(session: PhoneSessionModel, to model: BabyHomeStatusModel) {
        switch session.mode {
        case .live:
            if let client = session.graphQLClient {
                model.useLive(client: client)
            } else {
                model.mode = .live
                model.graphQLClient = nil
                model.offlineStore = nil
                model.isConnected = session.isConnected
            }
        case .offline:
            if let store = session.offlineStore {
                model.useOffline(store: store)
            } else {
                model.mode = .offline
                model.graphQLClient = nil
                model.offlineStore = nil
                model.isConnected = session.isConnected
            }
        case .sample:
            if session.isConnected {
                model.useSample()
            } else {
                model.graphQLClient = nil
                model.offlineStore = nil
                model.mode = .sample
                model.isConnected = false
                model.statusFail = nil
                model.lastFailedControl = nil
            }
        }
    }

    /// Load status for live; refresh offline snapshot otherwise.
    @MainActor
    static func refreshStatus(_ model: BabyHomeStatusModel) async {
        if model.mode == .live {
            await model.loadLiveStatus()
        } else if model.mode == .offline {
            await model.refreshOfflineSnapshot()
        }
    }
}
