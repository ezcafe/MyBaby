import SwiftUI

/// Shared copy for care chips — keeps identity when a live send fails.
enum CareControlLabels {
    static func mlTitle(_ ml: Int) -> String { "\(ml) ml" }

    static func failSubtitle(isFailed: Bool) -> String? {
        isFailed ? "Failed" : nil
    }

    /// Timed chip title: never wipe identity on fail.
    static func timedTitle(side: TimedChipSide, phase: TimedChipPhase, isFailed: Bool) -> String {
        if isFailed { return side.title }
        switch phase {
        case .idle: return side.title
        case .running: return side.runningTitle
        case .done: return "Done"
        }
    }

    static func timedSubtitle(
        side _: TimedChipSide,
        phase: TimedChipPhase,
        isFailed: Bool,
        elapsed: String
    ) -> String {
        if isFailed { return "Failed" }
        switch phase {
        case .idle: return ""
        case .running: return elapsed
        case .done: return ""
        }
    }
}

struct CareSectionHeader: View {
    @Environment(\.colorScheme) private var scheme
    let lead: String
    let detail: String?
    var isUpdating: Bool = false

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        VStack(alignment: .leading, spacing: 4) {
            Text(lead)
                .font(.headline.weight(.bold))
                .foregroundStyle(p.foreground)
            if let detail, !detail.isEmpty {
                Text(detail)
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(p.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if isUpdating {
                Text("Updating…")
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(p.muted)
                    .accessibilityLabel("Updating")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CareFooterSlot: View {
    @Environment(\.colorScheme) private var scheme
    let content: CareFooterContent
    var onRetry: (() -> Void)?
    var onDiscard: (() -> Void)?

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        switch content {
        case .none:
            EmptyView()
        case .tip(let message):
            Text(message)
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(p.muted)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .statusFail(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(p.muted)
                if let onRetry {
                    Button("Retry", action: onRetry)
                        .tint(p.accent)
                }
            }
        case .recovery(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(p.muted)
                HStack {
                    if let onRetry {
                        Button("Retry", action: onRetry)
                    }
                    if let onDiscard {
                        Button("Discard", action: onDiscard)
                    }
                }
                .tint(p.accent)
            }
        }
    }
}

struct TimedCareChip: View {
    @Environment(\.colorScheme) private var scheme
    let side: TimedChipSide
    let phase: TimedChipPhase
    var isFailed: Bool = false
    /// When false, running chips show a static elapsed label (no 1 Hz TimelineView).
    var ticksEnabled: Bool = true
    let action: () -> Void

    /// Feed L/R and Pump L/R/Both share amount-chip height; Sleep stays roomier.
    private var isCompact: Bool {
        switch side {
        case .breastLeft, .breastRight, .pumpLeft, .pumpRight, .pumpBoth: return true
        case .nap: return false
        }
    }

    private var useTimeline: Bool {
        if isFailed { return false }
        if case .running = phase {
            return ticksEnabled
        }
        return false
    }

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        Button(action: action) {
            // Scope timer ticks to the chip label only — never rebuild TabView.
            if useTimeline {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    chipLabel(now: context.date, palette: p)
                }
            } else {
                chipLabel(now: .now, palette: p)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel({
            let sub = subtitle(now: .now)
            return sub.isEmpty ? title : "\(title), \(sub)"
        }())
    }

    @ViewBuilder
    private func chipLabel(now: Date, palette: BabyPalette) -> some View {
        let sub = subtitle(now: now)
        let label = VStack(spacing: isCompact ? 1 : 4) {
            Text(title)
                .font(isCompact ? .caption.weight(.bold) : .headline.weight(.bold))
                .foregroundStyle(titleColor(palette))
            if !sub.isEmpty {
                Text(sub)
                    .font(BabyTokens.secondaryFont)
                    .foregroundStyle(subtitleColor(palette))
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)

        Group {
            if isCompact {
                label
                    .padding(.horizontal, 8)
                    .frame(height: BabyTokens.careChipHeight)
            } else {
                label
                    .frame(minHeight: BabyTokens.minHit)
                    .padding(10)
            }
        }
        .background(chipBackgroundView(palette))
        .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous)
                .stroke(isFailed ? palette.danger : Color.clear, lineWidth: isFailed ? 1 : 0)
        )
    }

    private func titleColor(_ palette: BabyPalette) -> Color {
        if isFailed { return palette.danger }
        return isAccent ? palette.accentForeground : palette.foreground
    }

    private func subtitleColor(_ palette: BabyPalette) -> Color {
        if isFailed { return palette.danger }
        return isAccent ? palette.accentForeground.opacity(0.85) : palette.muted
    }

    @ViewBuilder
    private func chipBackgroundView(_ palette: BabyPalette) -> some View {
        if isFailed {
            palette.dangerSurface
        } else if isAccent {
            palette.accent
        } else {
            Rectangle().fill(.ultraThinMaterial)
        }
    }

    private var isAccent: Bool {
        if isFailed { return false }
        if case .running = phase { return true }
        if case .done = phase { return true }
        return false
    }

    private var title: String {
        CareControlLabels.timedTitle(side: side, phase: phase, isFailed: isFailed)
    }

    private func subtitle(now: Date) -> String {
        let elapsed: String = {
            if case .running(let startedAt) = phase {
                return BabyCarePrimarySignal.formatTimer(now.timeIntervalSince(startedAt))
            }
            return ""
        }()
        return CareControlLabels.timedSubtitle(
            side: side,
            phase: phase,
            isFailed: isFailed,
            elapsed: elapsed
        )
    }
}

/// 3 recommendation ml chips + Custom, stacked vertically. Accent = done flash only.
struct CareMlAmountGrid: View {
    @Environment(\.colorScheme) private var scheme
    let mls: [Int]
    let doneMl: Int?
    var failedMl: Int? = nil
    let onSelect: (Int) -> Void
    let onCustom: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        let chips = Array(mls.prefix(3))
        VStack(spacing: 6) {
            ForEach(chips, id: \.self) { ml in
                let on = doneMl == ml && failedMl != ml
                let failed = failedMl == ml
                Button {
                    onSelect(ml)
                } label: {
                    VStack(spacing: 1) {
                        Text(CareControlLabels.mlTitle(ml))
                            .font(.headline.weight(.bold))
                        if let fail = CareControlLabels.failSubtitle(isFailed: failed) {
                            Text(fail)
                                .font(BabyTokens.secondaryFont)
                        }
                    }
                    .multilineTextAlignment(.center)
                    .foregroundStyle(failed ? p.danger : (on ? p.accentForeground : p.foreground))
                    .frame(maxWidth: .infinity)
                    .frame(height: BabyTokens.careChipHeight)
                    .background {
                        if failed {
                            p.dangerSurface
                        } else if on {
                            p.accent
                        } else {
                            Rectangle().fill(.ultraThinMaterial)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                            .stroke(failed ? p.danger : Color.clear, lineWidth: failed ? 1 : 0)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(failed
                    ? "Bottle \(ml) milliliters, Failed"
                    : "Bottle \(ml) milliliters")
            }
            Button("Custom", action: onCustom)
                .font(.headline.weight(.bold))
                .foregroundStyle(p.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: BabyTokens.careChipHeight)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                .buttonStyle(.plain)
                .accessibilityLabel("Custom bottle amount")
        }
    }
}

struct DiaperKindGrid: View {
    static let iconTitleSpacing: CGFloat = 0
    static var titleFont: Font { .caption2.weight(.semibold) }
    static var chipHeight: CGFloat { BabyTokens.careChipHeight }

    @Environment(\.colorScheme) private var scheme
    let done: DiaperKind?
    var failed: DiaperKind? = nil
    let onSelect: (DiaperKind) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(DiaperKind.allCases) { kind in
                let on = done == kind && failed != kind
                let isFail = failed == kind
                Button {
                    onSelect(kind)
                } label: {
                    VStack(spacing: Self.iconTitleSpacing) {
                        Image(systemName: kind.systemImage)
                            .font(.caption.weight(.semibold))
                        Text(kind.rawValue)
                            .font(Self.titleFont)
                        if CareControlLabels.failSubtitle(isFailed: isFail) != nil {
                            Text("Failed")
                                .font(BabyTokens.secondaryFont)
                        }
                    }
                    .foregroundStyle(isFail ? p.danger : (on ? p.accentForeground : p.foreground))
                    .frame(maxWidth: .infinity)
                    .frame(height: Self.chipHeight)
                    .background {
                        if isFail {
                            p.dangerSurface
                        } else if on {
                            p.accent
                        } else {
                            Rectangle().fill(.ultraThinMaterial)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                            .stroke(isFail ? p.danger : Color.clear, lineWidth: isFail ? 1 : 0)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isFail ? "\(kind.rawValue) diaper, Failed" : "\(kind.rawValue) diaper")
            }
        }
    }
}
