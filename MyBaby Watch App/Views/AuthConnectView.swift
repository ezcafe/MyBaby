import SwiftUI

enum ConnectGuideCopy {
    static let title = "Quick connect"
    static let steps: [String] = [
        "On web: Settings → Device pairing → Baby Care → Generate code",
        "Pick Production (or Local for simulator)",
        "Enter code → Save & connect",
    ]
}

struct AuthConnectView: View {
    @Bindable var model: BabyHomeStatusModel
    var onDismiss: (() -> Void)?
    @Environment(\.colorScheme) private var scheme

    /// Default: Local selected, URL field hidden (`localPreset` under the hood).
    @State private var baseURL: String = BabyAPIConfig.localPreset
    @State private var selectedPreset: ConnectHostPreset = .local
    @State private var pairingCode: String = ""
    @State private var showHelp = false
    @State private var showAdvanced = false
    /// Do not preload Keychain into the field — cold start restores via BabySessionRestore.
    @State private var token: String = ""
    @State private var errorText: String?
    @State private var connecting = false

    private let tokenStore = BabyAPITokenStore()

    /// URL field only when Production is selected (Local hides it).
    private var showsURLField: Bool { ConnectHostURLField.isVisible(selected: selectedPreset) }

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(spacing: 10) {
                Text("API server")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                HStack(spacing: 6) {
                    presetButton("Local", preset: .local, palette: p) {
                        baseURL = BabyAPIConfig.localPreset
                        selectedPreset = .local
                        errorText = nil
                    }
                    presetButton("Production", preset: .production, palette: p) {
                        baseURL = ""
                        selectedPreset = .production
                        errorText = nil
                    }
                }

                if showsURLField {
                    TextField("https://…", text: urlFieldBinding)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }

                TextField("Pairing code", text: $pairingCode)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()

                if let errorText {
                    Text(errorText)
                        .font(.caption2)
                        .foregroundStyle(p.danger)
                        .multilineTextAlignment(.center)
                }

                Button(connecting ? "Connecting…" : "Save & connect") {
                    Task { await saveAndConnectLive() }
                }
                .tint(p.accent)
                .disabled(connecting)

                Button(showHelp ? "Hide help" : "Need help?") {
                    showHelp.toggle()
                }
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)

                if showHelp {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ConnectGuideCopy.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(p.foreground)
                        ForEach(Array(ConnectGuideCopy.steps.enumerated()), id: \.offset) { index, step in
                            Text("\(index + 1). \(step)")
                                .font(BabyTokens.secondaryFont)
                                .foregroundStyle(p.muted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Button(showAdvanced ? "Hide advanced paste" : "Advanced: paste token") {
                            showAdvanced.toggle()
                        }
                        .font(.caption2)
                        .padding(.top, 4)
                        if showAdvanced {
                            SecureField("mny_… token", text: $token)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                            Button("Save pasted credentials") {
                                saveAdvancedPaste()
                            }
                            .font(.caption2)
                        }
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
                }
            }
            .padding()
        }
        .background(p.background)
    }

    /// Edits keep Production selected so the field stays visible (Local tap is the only way to hide it).
    private var urlFieldBinding: Binding<String> {
        Binding(
            get: { baseURL },
            set: { newValue in
                baseURL = newValue
                selectedPreset = .production
            }
        )
    }

    private func presetButton(
        _ title: String,
        preset: ConnectHostPreset,
        palette: BabyPalette,
        action: @escaping () -> Void
    ) -> some View {
        let on = selectedPreset == preset
        return Button(action: action) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(on ? palette.accentForeground : palette.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: BabyTokens.careChipHeight)
                .background(on ? palette.accent : Color.clear)
                .background {
                    if !on { Rectangle().fill(.ultraThinMaterial) }
                }
                .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    @MainActor
    private func saveAndConnectLive() async {
        errorText = nil
        let code = pairingCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty {
            connecting = true
            defer { connecting = false }
            guard let origin = BabyAPIConfig.normalize(baseURL) ?? BabyAPIConfig.normalize(
                BabyAPIConfig.productionPairingOrigin
            ) else {
                errorText = "Enter a valid http(s) URL"
                return
            }
            let client = WatchPairClient(pairingOriginRaw: origin)
            do {
                let result = try await client.redeem(code: code)
                guard BabyAPIConfig.saveBaseURL(result.baseURL) else {
                    errorText = "Bad URL from server"
                    return
                }
                try tokenStore.save(result.token)
                baseURL = result.baseURL
                selectedPreset = .production
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
        // Status load is owned by BabyHomeView.task(id: mode) to avoid a double query.
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
