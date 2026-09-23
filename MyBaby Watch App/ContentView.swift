import SwiftUI

struct ContentView: View {
    @State private var model = BabyHomeStatusModel(snapshot: .sampleNextFeed())
    /// Previews and UI-first demos skip the auth stub.
    var bypassAuth: Bool = true

    var body: some View {
        Group {
            if bypassAuth || model.isConnected {
                NavigationStack {
                    BabyHomeView(model: model)
                }
            } else {
                AuthStubView(model: model)
            }
        }
        .onOpenURL { url in
            model.applyDeepLink(url)
            model.isConnected = true
        }
    }
}

#Preview {
    ContentView()
}
