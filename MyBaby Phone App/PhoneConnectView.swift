import SwiftUI

struct PhoneConnectView: View {
    @Bindable var session: PhoneSessionModel
    var onDismiss: (() -> Void)?

    @State private var baseURL: String = ConnectHostURLField.cloudDefaultURL
    @State private var selectedPreset: ConnectHostPreset = ConnectHostURLField.defaultPreset
    @State private var pairingCode: String = ""
    @State private var showHelp = false
    @State private var showAdvanced = false
    @State private var token: String = ""
    @State private var connecting = false

    private var showsURLField: Bool { ConnectHostURLField.isVisible(selected: selectedPreset) }
    private var showsPairing: Bool { ConnectHostURLField.showsPairingFields(selected: selectedPreset) }

    var body: some View {
        Form {
            Section {
                Text("Get started")
                    .font(.title2.weight(.semibold))
                    .accessibilityAddTraits(.isHeader)
                Text("Save care on this iPhone and Watch.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)

            Section {
                Picker("Mode", selection: $selectedPreset) {
                    Text("Offline").tag(ConnectHostPreset.offline)
                    Text("Cloud").tag(ConnectHostPreset.cloud)
                }
                .pickerStyle(.segmented)
                .accessibilityLabel("Connection mode")
                .onChange(of: selectedPreset) { _, preset in
                    applyPreset(preset)
                }

                if selectedPreset == .offline {
                    Text("Stores care in iCloud. No pairing code. Same store as Watch.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                if showsURLField {
                    TextField("https://…", text: $baseURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.URL)
                        .accessibilityLabel("Server URL")
                }

                if showsPairing {
                    TextField("Pairing code", text: $pairingCode)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Pairing code")
                }

                if let fail = session.statusFail {
                    Text(fail)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Error: \(fail)")
                }

                if selectedPreset == .offline {
                    Button("Start Offline") {
                        Task { await startOffline() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(connecting)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                } else if selectedPreset == .cloud {
                    Button(connecting ? "Connecting…" : "Save & connect") {
                        Task { await saveAndConnectLive() }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .disabled(connecting)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }

            Section {
                Button(showHelp ? "Hide help" : "Need help?") {
                    showHelp.toggle()
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if showHelp {
                    Text(ConnectGuideCopy.title)
                        .font(.subheadline.weight(.semibold))
                    ForEach(Array(ConnectGuideCopy.steps.enumerated()), id: \.offset) { index, step in
                        Text("\(index + 1). \(step)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    if selectedPreset == .cloud {
                        Button(showAdvanced ? "Hide advanced paste" : "Advanced: paste URL & token") {
                            showAdvanced.toggle()
                        }
                        .font(.footnote)
                        if showAdvanced {
                            SecureField("mny_… token", text: $token)
                                .accessibilityLabel("API token")
                            Button("Save pasted credentials") {
                                saveAdvancedPaste()
                            }
                            .font(.footnote)
                        }
                    }
                }
            }
        }
    }

    private func applyPreset(_ preset: ConnectHostPreset) {
        guard preset == .offline || preset == .cloud else { return }
        let next = ConnectPresetSelection.apply(preset, baseURL: baseURL)
        baseURL = next.baseURL
        selectedPreset = next.selected
        session.statusFail = nil
    }

    @MainActor
    private func startOffline() async {
        connecting = true
        defer { connecting = false }
        await session.useOffline()
        if session.isConnected {
            onDismiss?()
        }
    }

    @MainActor
    private func saveAndConnectLive() async {
        session.statusFail = nil
        let code = pairingCode.trimmingCharacters(in: .whitespacesAndNewlines)
        if !code.isEmpty {
            connecting = true
            defer { connecting = false }
            guard let origin = BabyAPIConfig.normalize(baseURL) ?? BabyAPIConfig.normalize(BabyAPIConfig.cloudPreset) else {
                session.statusFail = "Enter a valid http(s) URL"
                return
            }
            let client = WatchPairClient(pairingOriginRaw: origin)
            let ok = await session.connectWithPairingCode(code: code, pairClient: client)
            if ok {
                pairingCode = ""
                onDismiss?()
            }
            return
        }
        saveAdvancedPaste()
    }

    private func saveAdvancedPaste() {
        if session.connectWithPastedCredentials(baseURLRaw: baseURL, token: token) {
            onDismiss?()
        }
    }
}
