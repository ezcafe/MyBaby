import SwiftUI

struct BabyHomeView: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        TimelineView(.periodic(from: .now, by: 1)) { context in
            TabView(selection: $model.selectedPage) {
                FeedBottlePage(model: model)
                    .tag(BabyHomePage.feedBottle)
                SleepPage(model: model)
                    .tag(BabyHomePage.sleep)
                DiaperPage(model: model)
                    .tag(BabyHomePage.diaper)
                PumpPage(model: model)
                    .tag(BabyHomePage.pump)
                LastCarePage(model: model)
                    .tag(BabyHomePage.lastCare)
            }
            .tabViewStyle(.page)
            .navigationTitle(model.snapshot.title)
            .background(p.background)
            .onChange(of: context.date) { _, newDate in
                model.now = newDate
            }
        }
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
