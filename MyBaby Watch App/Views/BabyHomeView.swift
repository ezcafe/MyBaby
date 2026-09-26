import SwiftUI

struct BabyHomeView: View {
    @Bindable var model: BabyHomeStatusModel
    var onOpenSettings: (() -> Void)?
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
            pageSlot(.sleep, selected: selected) {
                SleepPage(model: model)
            }
            pageSlot(.diaper, selected: selected) {
                DiaperPage(model: model)
            }
            pageSlot(.pump, selected: selected) {
                PumpPage(model: model)
            }
            pageSlot(.lastCare, selected: selected) {
                LastCarePage(model: model)
            }
        }
        .tabViewStyle(.page)
        .background(p.background)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    onOpenSettings?()
                } label: {
                    Image(systemName: "gearshape")
                }
                .accessibilityLabel("Settings")
            }
        }
        .task(id: model.mode) {
            if model.mode == .live {
                await model.loadLiveStatus()
            }
        }
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

#Preview("Next feed · light") {
    NavigationStack {
        BabyHomeView(model: BabyHomeStatusModel(snapshot: .sampleNextFeed(), isConnected: true))
    }
    .preferredColorScheme(.light)
}

#Preview("Open nap · dark") {
    NavigationStack {
        BabyHomeView(model: BabyHomeStatusModel(snapshot: .sampleOpenNap(), isConnected: true))
    }
    .preferredColorScheme(.dark)
}
