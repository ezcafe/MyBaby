import SwiftUI

struct FeedPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    @State private var showBottleSheet = false
    @State private var showCustomBottle = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .feed,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(
                lead: "Feed",
                detail: model.snapshot.feedHeaderDetail,
                isUpdating: false
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
            Button("Bottle") {
                showBottleSheet = true
            }
            .font(.headline.weight(.bold))
            .foregroundStyle(p.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: BabyTokens.careChipHeight)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
            .buttonStyle(.plain)
            .accessibilityLabel("Bottle")
            CareFooterSlot(
                content: model.footer(tip: model.snapshot.feedTip),
                onRetry: { Task { await model.retryLastFailure() } },
                onDiscard: { model.discardRecovery() }
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showBottleSheet) {
            BottleAmountSheet(
                mls: model.snapshot.bottleChipMls,
                doneMl: model.bottleDoneMl,
                failedMl: {
                    if case .bottle(let ml) = model.lastFailedControl { return ml }
                    return nil
                }(),
                onSelect: { ml in
                    model.selectBottle(ml: ml)
                    showBottleSheet = false
                },
                onCustom: {
                    showBottleSheet = false
                    showCustomBottle = true
                }
            )
        }
        .sheet(isPresented: $showCustomBottle) {
            CustomMlPicker(title: "Bottle ml") { ml in
                model.selectBottle(ml: ml)
                showCustomBottle = false
            }
        }
    }
}

struct BottleAmountSheet: View {
    /// Contract: sheet title stays horizontally centered.
    static let titleIsCentered = true
    static let titleFrameAlignment: Alignment = .center

    @Environment(\.colorScheme) private var scheme
    let mls: [Int]
    let doneMl: Int?
    var failedMl: Int? = nil
    let onSelect: (Int) -> Void
    let onCustom: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 10) {
            Text("Bottle ml")
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: Self.titleFrameAlignment)
            CareMlAmountGrid(
                mls: mls,
                doneMl: doneMl,
                failedMl: failedMl,
                onSelect: onSelect,
                onCustom: onCustom
            )
        }
        .padding()
    }
}

struct PumpAmountSheet: View {
    /// Contract: sheet title stays horizontally centered.
    static let titleIsCentered = true
    static let titleFrameAlignment: Alignment = .center

    @Environment(\.colorScheme) private var scheme
    let mls: [Int]
    let doneMl: Int?
    var failedMl: Int? = nil
    let onSelect: (Int) -> Void
    let onCustom: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 10) {
            Text("Pump ml")
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: Self.titleFrameAlignment)
            CareMlAmountGrid(
                mls: mls,
                doneMl: doneMl,
                failedMl: failedMl,
                onSelect: onSelect,
                onCustom: onCustom
            )
        }
        .padding()
    }
}

struct SleepPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .sleep,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Sleep", detail: nil, isUpdating: false)
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
        .environment(\.colorScheme, scheme)
    }
}

struct DiaperPage: View {
    @Bindable var model: BabyHomeStatusModel
    @State private var detailKind: DiaperKind?
    @State private var detailDraft = DiaperSheetDraft.openSheetDefaults()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Diaper", detail: nil, isUpdating: false)
            DiaperKindGrid(
                done: model.diaperDoneKind,
                failed: {
                    if case .diaper(let kind) = model.lastFailedControl { return kind }
                    return nil
                }(),
                onSelect: { kind in
                    switch planDiaperKindTap(kind) {
                    case .instantSave(let k):
                        model.selectDiaper(k)
                    case .openSheet(let k, let draft):
                        detailDraft = draft
                        detailKind = k
                    }
                }
            )
            CareFooterSlot(
                content: model.footer(tip: model.snapshot.diaperTip),
                onRetry: { Task { await model.retryLastFailure() } },
                onDiscard: { model.discardRecovery() }
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(item: $detailKind) { kind in
            DiaperDetailSheet(
                kind: kind,
                draft: $detailDraft,
                onCancel: { detailKind = nil },
                onSave: {
                    model.selectDiaper(kind, details: detailDraft)
                    detailKind = nil
                }
            )
        }
    }
}

struct DiaperDetailSheet: View {
    let kind: DiaperKind
    @Binding var draft: DiaperSheetDraft
    let onCancel: () -> Void
    let onSave: () -> Void
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Text(kind.rawValue)
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(p.muted)
                    .frame(maxWidth: .infinity, alignment: .center)

                detailSection(title: "Color") {
                    chipGrid(
                        DiaperDetailColor.allCases,
                        selectedId: draft.color?.id,
                        label: { $0.label }
                    ) { next in
                        draft.color = toggleOptionalDiaperChip(draft.color, next: next)
                    }
                }
                if draft.color?.isRedFlag == true {
                    Text("Color may need a clinician check.")
                        .font(BabyTokens.secondaryFont)
                        .foregroundStyle(p.danger)
                }

                detailSection(title: "Texture") {
                    chipGrid(
                        DiaperDetailTexture.allCases,
                        selectedId: draft.texture?.id,
                        label: { $0.label }
                    ) { next in
                        draft.texture = toggleOptionalDiaperChip(draft.texture, next: next)
                    }
                }
                if draft.texture?.needsCaution == true {
                    Text("Watery or hard may need a check.")
                        .font(BabyTokens.secondaryFont)
                        .foregroundStyle(p.danger)
                }

                detailSection(title: "Amount") {
                    chipGrid(
                        DiaperDetailAmount.allCases,
                        selectedId: draft.amount.id,
                        label: { $0.label }
                    ) { next in
                        draft.amount = next
                    }
                }

                HStack(spacing: 6) {
                    Button("Cancel", action: onCancel)
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: BabyTokens.careChipHeight)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                        .buttonStyle(.plain)
                    Button("Save", action: onSave)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(p.accentForeground)
                        .frame(maxWidth: .infinity)
                        .frame(height: BabyTokens.careChipHeight)
                        .background(p.accent)
                        .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                        .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private func detailSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(BabyPalette(scheme: scheme).muted)
            content()
        }
    }

    private func chipGrid<T: Identifiable>(
        _ items: [T],
        selectedId: T.ID?,
        label: @escaping (T) -> String,
        onTap: @escaping (T) -> Void
    ) -> some View where T.ID: Equatable {
        let columns = [GridItem(.flexible(), spacing: 6), GridItem(.flexible(), spacing: 6)]
        let p = BabyPalette(scheme: scheme)
        return LazyVGrid(columns: columns, spacing: 6) {
            ForEach(items) { item in
                let on = selectedId == item.id
                Button {
                    onTap(item)
                } label: {
                    Text(label(item))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(on ? p.accentForeground : p.foreground)
                        .frame(maxWidth: .infinity)
                        .frame(height: BabyTokens.careChipHeight)
                        .background {
                            if on {
                                p.accent
                            } else {
                                Rectangle().fill(.ultraThinMaterial)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
struct PumpPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.colorScheme) private var scheme
    @State private var showAmountSheet = false
    @State private var showCustom = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .pump,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Pump", detail: nil, isUpdating: false)
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
                HStack(spacing: 6) {
                    TimedCareChip(
                        side: .pumpBoth,
                        phase: model.pumpBoth,
                        isFailed: model.isFailed(.timed(.pumpBoth)),
                        ticksEnabled: ticksEnabled
                    ) {
                        model.toggleTimed(.pumpBoth)
                    }
                    Button("Amount") {
                        showAmountSheet = true
                    }
                    .font(.caption.weight(.bold))
                    .foregroundStyle(BabyTokens.foreground(scheme))
                    .frame(maxWidth: .infinity)
                    .frame(height: BabyTokens.careChipHeight)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
                    .buttonStyle(.plain)
                    .accessibilityLabel("Pump amount")
                }
            }
            CareFooterSlot(
                content: model.footer(tip: model.snapshot.pumpTip),
                onRetry: { Task { await model.retryLastFailure() } },
                onDiscard: { model.discardRecovery() }
            )
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showAmountSheet) {
            PumpAmountSheet(
                mls: model.snapshot.bottleChipMls,
                doneMl: model.pumpDoneMl,
                failedMl: {
                    if case .pump(let ml) = model.lastFailedControl { return ml }
                    return nil
                }(),
                onSelect: { ml in
                    model.selectPump(ml: ml)
                    showAmountSheet = false
                },
                onCustom: {
                    showAmountSheet = false
                    showCustom = true
                }
            )
        }
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
                CareSectionHeader(lead: "Last care", detail: nil, isUpdating: false)
                statusRow(model.snapshot.lastFeed, palette: p)
                statusRow(model.snapshot.lastNap, palette: p)
                statusRow(model.snapshot.lastDiaper, palette: p)
                statusRow(model.snapshot.lastPump, palette: p)
                Button("Settings") {
                    model.showSettingsSheet = true
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(p.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: BabyTokens.careChipHeight)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                .buttonStyle(.plain)
                .accessibilityLabel("Settings")
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statusRow(_ line: BabyCareStatusLine, palette: BabyPalette) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: line.iconSystemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            Text(line.sentence)
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(line.isEmpty ? palette.muted : palette.foreground)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// Gear sheet — host + Log out (caller confirms). Not a TabView page.
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
            Button("Log out", role: .destructive) {
                confirmLogout = true
            }
            .frame(maxWidth: .infinity)
            .frame(height: BabyTokens.careChipHeight)
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
    /// Contract for centered sheet title (Bottle / Pump custom ml).
    static let titleIsCentered = true
    static let titleFrameAlignment: Alignment = .center

    let title: String
    let onPick: (Int) -> Void
    @Environment(\.colorScheme) private var scheme
    @State private var ml: Double = 120

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: Self.titleFrameAlignment)
            Picker("ml", selection: $ml) {
                ForEach(Array(stride(from: 30, through: 240, by: 10)), id: \.self) { value in
                    Text("\(value) ml").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: Self.wheelHeight)
            Button("Save") { onPick(Int(ml)) }
                .font(.headline.weight(.bold))
                .frame(maxWidth: .infinity)
        }
        .padding()
    }
}
