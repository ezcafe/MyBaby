import SwiftUI

struct ContentView: View {
    @State private var model = BabyHomeStatusModel(snapshot: .sampleNextFeed())
    /// Previews skip the connect screen. Production uses `false`.
    var bypassAuth: Bool = true
    @State private var showConnect = false

    var body: some View {
        Group {
            if showConnect || AuthGate.showsConnect(bypassAuth: bypassAuth, isConnected: model.isConnected) {
                AuthConnectView(model: model) {
                    showConnect = false
                }
            } else {
                BabyHomeView(model: model, onOpenSettings: { showConnect = true })
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
    }
}

#Preview {
    ContentView(bypassAuth: true)
}
