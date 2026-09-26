import SwiftUI

struct AuthConnectView: View {
    @Bindable var model: BabyHomeStatusModel
    var onDismiss: (() -> Void)?
    @Environment(\.colorScheme) private var scheme

    @State private var baseURL: String = BabyAPIConfig.loadBaseURL()
    @State private var pairingCode: String = ""
    @State private var showAdvanced = false
    @State private var token: String = BabyAPITokenStore().load() ?? ""
    @State private var errorText: String?
    @State private var connecting = false

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

                TextField("Pairing code", text: $pairingCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()

                if let errorText {
                    Text(errorText)
                        .font(.caption2)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button(connecting ? "Connecting…" : "Save & connect") {
                    Task { await saveAndConnectLive() }
                }
                .tint(p.accent)
                .disabled(connecting)

                Button("Continue with sample") {
                    model.useSample()
                    onDismiss?()
                }
                .font(.caption)

                Button(showAdvanced ? "Hide advanced paste" : "Advanced: paste URL & token") {
                    showAdvanced.toggle()
                }
                .font(.caption2)

                if showAdvanced {
                    TextField("https://…", text: $baseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    SecureField("mny_… token", text: $token)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button("Save pasted credentials") {
                        saveAdvancedPaste()
                    }
                    .font(.caption2)
                }
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

    @MainActor
    private func saveAndConnectLive() async {
        errorText = nil
        let code = pairingCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty {
            connecting = true
            defer { connecting = false }
            let origin = BabyAPIConfig.normalize(baseURL) ?? BabyAPIConfig.productionPairingOrigin
            let client = WatchPairClient(pairingOriginRaw: origin)
            do {
                let result = try await client.redeem(code: code)
                guard BabyAPIConfig.saveBaseURL(result.baseURL) else {
                    errorText = "Bad URL from server"
                    return
                }
                try tokenStore.save(result.token)
                baseURL = result.baseURL
                token = result.token
                pairingCode = ""
                enterLive(token: result.token)
            } catch let err as WatchPairError {
                errorText = watchPairUserMessage(err)
            } catch {
                errorText = "Could not connect"
            }
            return
        }
        saveAdvancedPaste()
    }

    private func saveAdvancedPaste() {
        guard BabyAPIConfig.saveBaseURL(baseURL) else {
            errorText = "Enter a valid http(s) URL"
            return
        }
        let trimmedToken = token.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedToken.isEmpty else {
            errorText = "Enter a pairing code or paste a Baby API token (mny_…)"
            return
        }
        do {
            try tokenStore.save(trimmedToken)
        } catch {
            errorText = "Could not save token"
            return
        }
        enterLive(token: trimmedToken)
    }

    private func enterLive(token: String) {
        let origin = BabyAPIConfig.loadBaseURL()
        let client = BabyGraphQLClient(baseURLRaw: origin, token: token)
        model.useLive(client: client)
        errorText = nil
        onDismiss?()
        Task { await model.loadLiveStatus() }
    }

    private func watchPairUserMessage(_ err: WatchPairError) -> String {
        switch err {
        case .emptyCode:
            return "Enter a pairing code"
        case .badURL:
            return "Bad pairing server URL"
        case .pairCode("EXPIRED"):
            return "Code expired — generate a new one on the web"
        case .pairCode("CONSUMED"):
            return "Code already used — generate a new one"
        case .pairCode("INVALID_CODE"), .pairCode("BAD_REQUEST"):
            return "Invalid or expired code — generate a new one on the web"
        case .pairCode("RATE_LIMITED"):
            return "Too many tries — wait and retry"
        case .pairCode:
            return "Could not redeem code"
        case .httpStatus, .transport:
            return "Network error"
        case .decoding:
            return "Bad server response"
        }
    }
}
