import SwiftUI

struct BabyHomeView: View {
    @Bindable var model: BabyHomeStatusModel
    var onOpenConnect: (() -> Void)?
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let selected = model.selectedPage
        // Do not wrap TabView in TimelineView — 1s rebuilds cancel in-flight gestures.
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
        .tabViewStyle(.verticalPage)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if model.isStatusLoading {
                    ProgressView()
                        .controlSize(.mini)
                        .accessibilityLabel("Updating")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                if model.lastFailedControl != nil || model.statusFail != nil {
                    Button("Retry") {
                        Task { await model.retryLastFailure() }
                    }
                    .tint(BabyTokens.accent(scheme))
                }
            }
        }
        .sheet(isPresented: $model.showSettingsSheet) {
            SettingsSheet(model: model) {
                onOpenConnect?()
            }
        }
        .task(id: model.mode) {
            if model.mode == .live {
                await model.loadLiveStatus()
            } else {
                model.persistStatusForWidgets()
            }
        }
    }

    @ViewBuilder
    private func pageSlot<Content: View>(
        _ page: BabyHomePage,
        selected: BabyHomePage,
        @ViewBuilder content: () -> Content
    ) -> some View {
        let bg = CarePageBackground.kind(page: page, snapshot: model.snapshot)
        Group {
            if BabyHomePage.shouldMount(page, selected: selected) {
                content()
                    .containerBackground(for: .tabView) {
                        CarePageBackgroundFill.containerFill(bg, scheme: scheme)
                    }
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
