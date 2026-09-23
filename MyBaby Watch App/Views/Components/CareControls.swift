import SwiftUI

struct CareSectionHeader: View {
    @Environment(\.colorScheme) private var scheme
    let lead: String
    let detail: String?

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
    let action: () -> Void

    /// Pump L/R/Both match amount-chip height; Feed/Sleep keep roomier chrome.
    private var isCompact: Bool {
        switch side {
        case .pumpLeft, .pumpRight, .pumpBoth: return true
        case .breastLeft, .breastRight, .nap: return false
        }
    }

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        Button(action: action) {
            // Scope timer ticks to the chip label only — never rebuild TabView.
            if case .running = phase {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    chipLabel(now: context.date, palette: p)
                }
            } else {
                chipLabel(now: .now, palette: p)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func chipLabel(now: Date, palette: BabyPalette) -> some View {
        let label = VStack(alignment: .leading, spacing: isCompact ? 1 : 4) {
            Text(title)
                .font(isCompact ? .caption.weight(.bold) : .headline.weight(.bold))
                .foregroundStyle(isAccent ? palette.accentForeground : palette.foreground)
            Text(subtitle(now: now))
                .font(BabyTokens.secondaryFont)
                .foregroundStyle(isAccent ? palette.accentForeground.opacity(0.85) : palette.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Group {
            if isCompact {
                label
                    .padding(.horizontal, 8)
                    .frame(height: BabyTokens.careChipHeight)
            } else {
                label
                    .frame(minHeight: BabyTokens.minHit, alignment: .leading)
                    .padding(10)
            }
        }
        .background(isAccent ? palette.accent : palette.surface)
        .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous)
                .stroke(palette.hairline, lineWidth: 1)
        )
    }

    private var isAccent: Bool {
        if case .running = phase { return true }
        if case .done = phase { return true }
        return false
    }

    private var title: String {
        switch phase {
        case .idle:
            return side.title
        case .running:
            return side.runningTitle
        case .done:
            return "Done"
        }
    }

    private func subtitle(now: Date) -> String {
        switch phase {
        case .idle:
            return side.idleSubtitle
        case .running(let startedAt):
            return BabyCarePrimarySignal.formatTimer(now.timeIntervalSince(startedAt))
        case .done:
            return " "
        }
    }
}

/// 3 recommendation ml chips + full-width Custom on row 2. Accent = done flash only.
struct CareMlAmountGrid: View {
    @Environment(\.colorScheme) private var scheme
    let mls: [Int]
    let doneMl: Int?
    let onSelect: (Int) -> Void
    let onCustom: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        let chips = Array(mls.prefix(3))
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(chips, id: \.self) { ml in
                    let on = doneMl == ml
                    Button("\(ml)") {
                        onSelect(ml)
                    }
                    .font(.headline.weight(.bold))
                    .foregroundStyle(on ? p.accentForeground : p.foreground)
                    .frame(maxWidth: .infinity)
                    .frame(height: BabyTokens.careChipHeight)
                    .background(on ? p.accent : p.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                            .stroke(p.hairline, lineWidth: 1)
                    )
                    .buttonStyle(.plain)
                }
            }
            Button("Custom", action: onCustom)
                .font(.headline.weight(.bold))
                .foregroundStyle(p.foreground)
                .frame(maxWidth: .infinity)
                .frame(height: BabyTokens.careChipHeight)
                .background(p.surface)
                .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                        .stroke(p.hairline, lineWidth: 1)
                )
                .buttonStyle(.plain)
        }
    }
}

struct DiaperKindGrid: View {
    static let iconTitleSpacing: CGFloat = 0
    /// Smaller than caption so icon + label fit the tile.
    static let titleFontSize: CGFloat = 10
    static var titleFont: Font { .system(size: titleFontSize, weight: .semibold) }
    static var chipHeight: CGFloat { BabyTokens.careChipHeight }

    @Environment(\.colorScheme) private var scheme
    let done: DiaperKind?
    let onSelect: (DiaperKind) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        LazyVGrid(columns: columns, spacing: 6) {
            ForEach(DiaperKind.allCases) { kind in
                let on = done == kind
                Button {
                    onSelect(kind)
                } label: {
                    VStack(spacing: Self.iconTitleSpacing) {
                        Image(systemName: kind.systemImage)
                            .font(.caption.weight(.semibold))
                        Text(kind.rawValue)
                            .font(Self.titleFont)
                    }
                    .foregroundStyle(on ? p.accentForeground : p.foreground)
                    .frame(maxWidth: .infinity)
                    .frame(height: Self.chipHeight)
                    .background(on ? p.accent : p.surface)
                    .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                            .stroke(p.hairline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
