import SwiftUI

struct FeedPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showCustomBottle = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .feed,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(
                    lead: "Feed",
                    detail: model.snapshot.feedHeaderDetail,
                    isUpdating: model.isStatusLoading
                )
                HStack(spacing: 8) {
                    TimedCareChip(
                        side: .breastLeft,
                        phase: model.breastLeft,
                        isFailed: model.isFailed(.timed(.breastLeft)),
                        ticksEnabled: ticksEnabled
                    ) {
                        model.toggleTimed(.breastLeft)
                    }
                    TimedCareChip(
                        side: .breastRight,
                        phase: model.breastRight,
                        isFailed: model.isFailed(.timed(.breastRight)),
                        ticksEnabled: ticksEnabled
                    ) {
                        model.toggleTimed(.breastRight)
                    }
                }
                CareMlAmountGrid(
                    mls: model.snapshot.bottleChipMls,
                    doneMl: model.bottleDoneMl,
                    failedMl: {
                        if case .bottle(let ml) = model.lastFailedControl { return ml }
                        return nil
                    }(),
                    onSelect: { model.selectBottle(ml: $0) },
                    onCustom: { showCustomBottle = true }
                )
                CareFooterSlot(
                    content: model.footer(tip: model.snapshot.feedTip),
                    onRetry: { Task { await model.retryLastFailure() } },
                    onDiscard: { model.discardRecovery() }
                )
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showCustomBottle) {
            CustomMlPicker(title: "Bottle ml") { ml in
                model.selectBottle(ml: ml)
                showCustomBottle = false
            }
        }
    }
}

struct SleepPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .sleep,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Sleep", detail: nil, isUpdating: model.isStatusLoading)
            TimedCareChip(
                side: .nap,
                phase: model.nap,
                isFailed: model.isFailed(.timed(.nap)),
                ticksEnabled: ticksEnabled
            ) {
                model.toggleTimed(.nap)
            }
            CareFooterSlot(
                content: model.footer(tip: model.snapshot.sleepTip),
                onRetry: { Task { await model.retryLastFailure() } },
                onDiscard: { model.discardRecovery() }
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct DiaperPage: View {
    @Bindable var model: BabyHomeStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Diaper", detail: nil, isUpdating: model.isStatusLoading)
            DiaperKindGrid(
                done: model.diaperDoneKind,
                failed: {
                    if case .diaper(let kind) = model.lastFailedControl { return kind }
                    return nil
                }(),
                onSelect: { model.selectDiaper($0) }
            )
            CareFooterSlot(
                content: model.footer(tip: model.snapshot.diaperTip),
                onRetry: { Task { await model.retryLastFailure() } },
                onDiscard: { model.discardRecovery() }
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct PumpPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showCustom = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .pump,
            sceneActive: scenePhase == .active
        )
    }

    /// Header uses last-pump status cue when present; tip stays in footer only.
    private var pumpHeaderDetail: String? {
        let line = model.snapshot.lastPump
        if line.isEmpty { return nil }
        return line.sentence
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(
                    lead: "Pump",
                    detail: pumpHeaderDetail,
                    isUpdating: model.isStatusLoading
                )
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        TimedCareChip(
                            side: .pumpLeft,
                            phase: model.pumpLeft,
                            isFailed: model.isFailed(.timed(.pumpLeft)),
                            ticksEnabled: ticksEnabled
                        ) {
                            model.toggleTimed(.pumpLeft)
                        }
                        TimedCareChip(
                            side: .pumpRight,
                            phase: model.pumpRight,
                            isFailed: model.isFailed(.timed(.pumpRight)),
                            ticksEnabled: ticksEnabled
                        ) {
                            model.toggleTimed(.pumpRight)
                        }
                    }
                    TimedCareChip(
                        side: .pumpBoth,
                        phase: model.pumpBoth,
                        isFailed: model.isFailed(.timed(.pumpBoth)),
                        ticksEnabled: ticksEnabled
                    ) {
                        model.toggleTimed(.pumpBoth)
                    }
                }
                CareMlAmountGrid(
                    mls: model.snapshot.bottleChipMls,
                    doneMl: model.pumpDoneMl,
                    failedMl: {
                        if case .pump(let ml) = model.lastFailedControl { return ml }
                        return nil
                    }(),
                    onSelect: { model.selectPump(ml: $0) },
                    onCustom: { showCustom = true }
                )
                CareFooterSlot(
                    content: model.footer(tip: model.snapshot.pumpTip),
                    onRetry: { Task { await model.retryLastFailure() } },
                    onDiscard: { model.discardRecovery() }
                )
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showCustom) {
            CustomMlPicker(title: "Pump ml") { ml in
                model.selectPump(ml: ml)
                showCustom = false
            }
        }
    }
}

struct LastCarePage: View {
    @Environment(\.colorScheme) private var scheme
    @Bindable var model: BabyHomeStatusModel

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CareSectionHeader(
                    lead: model.snapshot.lastCareHeaderLead,
                    detail: nil,
                    isUpdating: model.isStatusLoading
                )
                statusRow(model.snapshot.lastFeed, palette: p)
                statusRow(model.snapshot.lastNap, palette: p)
                statusRow(model.snapshot.lastDiaper, palette: p)
                statusRow(model.snapshot.lastPump, palette: p)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statusRow(_ line: BabyCareStatusLine, palette: BabyPalette) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: line.iconSystemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            Text(line.sentence)
                .font(.caption)
                .foregroundStyle(line.isEmpty ? palette.muted : palette.foreground)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Gear sheet — host, Log out (caller confirms), Reconnect. Not a TabView page.
struct SettingsSheet: View {
    @Bindable var model: BabyHomeStatusModel
    var onReconnect: () -> Void
    @Environment(\.colorScheme) private var scheme
    @State private var confirmLogout = false

    private var hostLine: String {
        let raw = BabyAPIConfig.loadBaseURL()
        if let origin = BabyAPIConfig.normalize(raw) {
            return "Connected · \(origin.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: ""))"
        }
        return raw.isEmpty ? "Not connected" : "Connected · \(raw)"
    }

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Settings", detail: nil)
            Text(hostLine)
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("Log out") {
                confirmLogout = true
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(p.danger)
            .frame(maxWidth: .infinity)
            .frame(height: BabyTokens.careChipHeight)
            .background(p.surface)
            .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous)
                    .stroke(p.danger, lineWidth: 1)
            )
            .buttonStyle(.plain)
            Button("Reconnect") {
                model.showSettingsSheet = false
                onReconnect()
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(p.accentForeground)
            .frame(maxWidth: .infinity)
            .frame(height: BabyTokens.careChipHeight)
            .background(p.accent)
            .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
            .buttonStyle(.plain)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .confirmationDialog("Log out?", isPresented: $confirmLogout, titleVisibility: .visible) {
            Button("Log out", role: .destructive) {
                model.logout()
                model.showSettingsSheet = false
                onReconnect()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

struct CustomMlPicker: View {
    static let visibleRowCount = 3
    static let rowHeight: CGFloat = 28
    static var wheelHeight: CGFloat { CGFloat(visibleRowCount) * rowHeight }

    let title: String
    let onPick: (Int) -> Void
    @State private var ml: Double = 120

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Picker("ml", selection: $ml) {
                ForEach(Array(stride(from: 30, through: 240, by: 10)), id: \.self) { value in
                    Text("\(value) ml").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: Self.wheelHeight)
            Button("Save") { onPick(Int(ml)) }
        }
        .padding()
    }
}
