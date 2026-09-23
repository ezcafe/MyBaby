import SwiftUI

struct BabyHomeView: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        // Do not wrap TabView in TimelineView — 1s rebuilds cancel in-flight gestures.
        // No navigationTitle — Gate A2 removed app title chrome.
        TabView(selection: $model.selectedPage) {
            FeedPage(model: model)
                .tag(BabyHomePage.feed)
            BottlePage(model: model)
                .tag(BabyHomePage.bottle)
            SleepPage(model: model)
                .tag(BabyHomePage.sleep)
            DiaperPage(model: model)
                .tag(BabyHomePage.diaper)
            PumpPage(model: model)
                .tag(BabyHomePage.pump)
            PumpAmountPage(model: model)
                .tag(BabyHomePage.pumpAmount)
            LastCarePage(model: model)
                .tag(BabyHomePage.lastCare)
        }
        .tabViewStyle(.page)
        .background(p.background)
    }
}

struct AuthStubView: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(spacing: 12) {
            Text("Connect iPhone / API token")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("UI stub — use sample care home for now.")
                .font(.caption)
                .foregroundStyle(p.muted)
                .multilineTextAlignment(.center)
            Button("Continue with sample") {
                model.isConnected = true
            }
            .tint(p.accent)
        }
        .padding()
        .background(p.background)
    }
}

#Preview("Next feed · light") {
    NavigationStack {
        BabyHomeView(model: BabyHomeStatusModel(snapshot: .sampleNextFeed()))
    }
    .preferredColorScheme(.light)
}

#Preview("Open nap · dark") {
    NavigationStack {
        BabyHomeView(model: BabyHomeStatusModel(snapshot: .sampleOpenNap()))
    }
    .preferredColorScheme(.dark)
}
