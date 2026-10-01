import SwiftUI

struct PhoneSettingsSheet: View {
    @Bindable var session: PhoneSessionModel
    var onLeftSession: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var confirmLeave = false

    var body: some View {
        NavigationStack {
            List {
                Section("Session") {
                    LabeledContent("Mode", value: modeLabel)
                    LabeledContent("iCloud", value: session.iCloudStatusText)
                }
                Section {
                    Button("Leave \(modeLabel)", role: .destructive) {
                        confirmLeave = true
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Leave \(modeLabel)?",
                isPresented: $confirmLeave,
                titleVisibility: .visible
            ) {
                Button("Leave \(modeLabel)", role: .destructive) {
                    session.leave()
                    onLeftSession()
                    dismiss()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You’ll need to connect again.")
            }
        }
    }

    private var modeLabel: String {
        switch session.mode {
        case .offline: return "Offline"
        case .live: return "Cloud"
        case .sample: return "Sample"
        }
    }
}
