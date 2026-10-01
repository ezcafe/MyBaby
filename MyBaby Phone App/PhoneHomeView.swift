import SwiftUI

struct PhoneHomeView: View {
    @Bindable var session: PhoneSessionModel
    var onOpenConnect: () -> Void
    @State private var care: BabyHomeStatusModel
    @State private var showSettings = false

    init(session: PhoneSessionModel, onOpenConnect: @escaping () -> Void) {
        self.session = session
        self.onOpenConnect = onOpenConnect
        _care = State(initialValue: PhoneCareWiring.makeModel(from: session))
    }

    var body: some View {
        TabView(selection: $care.selectedPage) {
            FeedPage(model: care)
                .tabItem { Label("Feed", systemImage: "fork.knife") }
                .tag(BabyHomePage.feed)
            SleepPage(model: care)
                .tabItem { Label("Sleep", systemImage: "moon.zzz.fill") }
                .tag(BabyHomePage.sleep)
            DiaperPage(model: care)
                .tabItem { Label("Diaper", systemImage: "toilet.fill") }
                .tag(BabyHomePage.diaper)
            PumpPage(model: care)
                .tabItem { Label("Pump", systemImage: "drop.fill") }
                .tag(BabyHomePage.pump)
            LastCarePage(model: care)
                .tabItem { Label("Status", systemImage: "list.bullet") }
                .tag(BabyHomePage.lastCare)
        }
        .tint(.teal)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if care.isStatusLoading {
                    ProgressView()
                        .controlSize(.mini)
                        .accessibilityLabel("Updating")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if care.lastFailedControl != nil || care.statusFail != nil {
                    Button("Retry") {
                        Task { await care.retryLastFailure() }
                    }
                    .accessibilityLabel("Retry")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .task(id: session.mode) {
            PhoneCareWiring.apply(session: session, to: care)
            await PhoneCareWiring.refreshStatus(care)
        }
        .onChange(of: session.isConnected) { _, connected in
            PhoneCareWiring.apply(session: session, to: care)
            if !connected {
                onOpenConnect()
            }
        }
        .sheet(isPresented: $showSettings) {
            PhoneSettingsSheet(session: session, onLeftSession: {
                showSettings = false
                care.logout()
                onOpenConnect()
            })
        }
    }
}
