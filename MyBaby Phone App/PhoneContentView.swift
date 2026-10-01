import SwiftUI

struct PhoneContentView: View {
    @State private var session: PhoneSessionModel
    var bypassAuth: Bool = false
    @State private var showConnect = false

    init(bypassAuth: Bool = false) {
        self.bypassAuth = bypassAuth
        _session = State(initialValue: PhoneSessionModel())
    }

    var body: some View {
        Group {
            if showConnect || AuthGate.showsConnect(bypassAuth: bypassAuth, isConnected: session.isConnected) {
                PhoneConnectView(session: session) {
                    showConnect = false
                }
            } else {
                NavigationStack {
                    PhoneHomeView(session: session, onOpenConnect: { showConnect = true })
                }
            }
        }
        .task {
            guard !bypassAuth else { return }
            await session.restoreColdStart()
        }
        .onChange(of: session.isConnected) { _, connected in
            if !connected { showConnect = true }
        }
    }
}

#Preview {
    PhoneContentView(bypassAuth: true)
}
