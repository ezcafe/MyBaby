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

struct AuthConnectView: View {
    @Bindable var model: BabyHomeStatusModel
    var onDismiss: (() -> Void)?
    @Environment(\.colorScheme) private var scheme

    @State private var baseURL: String = BabyAPIConfig.loadBaseURL()
    @State private var token: String = BabyAPITokenStore().load() ?? ""
    @State private var errorText: String?

    private let tokenStore = BabyAPITokenStore()

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(spacing: 10) {
                Text("API server")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text(displayHost)
                    .font(.caption2)
                    .foregroundStyle(p.muted)
                    .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    Button("Local") {
                        baseURL = BabyAPIConfig.localPreset
                        errorText = nil
                    }
                    Button("Production") {
                        baseURL = BabyAPIConfig.productionPreset
                        errorText = nil
                    }
                }
                .font(.caption2)

                TextField("https://…", text: $baseURL)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                SecureField("mny_… token", text: $token)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                if let errorText {
                    Text(errorText)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button("Save & connect") {
                    saveAndConnectLive()
                }
                .tint(p.accent)

                Button("Continue with sample") {
                    model.useSample()
                    onDismiss?()
                }
                .font(.caption)
            }
            .padding()
        }
        .background(p.background)
    }

    private var displayHost: String {
        if let origin = BabyAPIConfig.normalize(baseURL) {
            return origin
        }
        return baseURL.isEmpty ? "No URL set" : "Invalid URL"
    }

    private func saveAndConnectLive() {
        guard BabyAPIConfig.saveBaseURL(baseURL) else {
            errorText = "Enter a valid http(s) URL"
            return
        }
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            errorText = "Paste a Baby API token (mny_…)"
            return
        }
        do {
            try tokenStore.save(trimmedToken)
        } catch {
            errorText = "Could not save token"
            return
        }
        let origin = BabyAPIConfig.loadBaseURL()
        let client = BabyGraphQLClient(baseURLRaw: origin, token: trimmedToken)
        model.useLive(client: client)
        errorText = nil
        onDismiss?()
        Task { await model.loadLiveStatus() }
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
