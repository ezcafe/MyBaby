import SwiftUI

struct BabyHomeView: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        let selected = model.selectedPage
        // Do not wrap TabView in TimelineView — 1s rebuilds cancel in-flight gestures.
        // No navigationTitle — Gate A2 removed app title chrome.
        // Mount only selected ±1 neighbor so far pages do not stay resident.
        TabView(selection: $model.selectedPage) {
            pageSlot(.feed, selected: selected) {
                FeedPage(model: model)
            }
            pageSlot(.bottle, selected: selected) {
                BottlePage(model: model)
            }
            pageSlot(.sleep, selected: selected) {
                SleepPage(model: model)
            }
            pageSlot(.diaper, selected: selected) {
                DiaperPage(model: model)
            }
            pageSlot(.pump, selected: selected) {
                PumpPage(model: model)
            }
            pageSlot(.pumpAmount, selected: selected) {
                PumpAmountPage(model: model)
            }
            pageSlot(.lastCare, selected: selected) {
                LastCarePage(model: model)
            }
        }
        .tabViewStyle(.page)
        .background(p.background)
    }

    @ViewBuilder
    private func pageSlot<Content: View>(
        _ page: BabyHomePage,
        selected: BabyHomePage,
        @ViewBuilder content: () -> Content
    ) -> some View {
        Group {
            if BabyHomePage.shouldMount(page, selected: selected) {
                content()
            } else {
                Color.clear
                    .accessibilityHidden(true)
            }
        }
        .tag(page)
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
