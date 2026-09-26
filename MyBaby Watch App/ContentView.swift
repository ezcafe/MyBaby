import SwiftUI

struct ContentView: View {
    @State private var model: BabyHomeStatusModel
    /// Previews skip the connect screen. Production uses `false`.
    var bypassAuth: Bool = true
    @State private var showConnect = false

    init(bypassAuth: Bool = true) {
        self.bypassAuth = bypassAuth
        if bypassAuth {
            _model = State(initialValue: BabyHomeStatusModel(snapshot: .sampleNextFeed()))
        } else {
            let model = BabyHomeStatusModel(snapshot: .sampleNextFeed())
            if let client = BabySessionRestore.makeLiveClientIfPossible() {
                model.useLive(client: client)
            }
            _model = State(initialValue: model)
        }
    }

    var body: some View {
        Group {
            if showConnect || AuthGate.showsConnect(bypassAuth: bypassAuth, isConnected: model.isConnected) {
                AuthConnectView(model: model) {
                    showConnect = false
                }
            } else {
                NavigationStack {
                    BabyHomeView(model: model, onOpenConnect: { showConnect = true })
                }
            }
        }
        .onOpenURL { url in
            model.applyDeepLink(url)
            if !model.isConnected {
                model.useSample()
            }
        }
        .onChange(of: model.needsReconnect) { _, needs in
            if needs { showConnect = true }
        }
        .onChange(of: model.isConnected) { _, connected in
            if !connected { showConnect = true }
        }
    }
}

#Preview {
    ContentView(bypassAuth: true)
}
