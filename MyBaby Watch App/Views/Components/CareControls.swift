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
                    .font(.caption)
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
                .font(.caption2)
                .foregroundStyle(p.muted)
                .frame(maxWidth: .infinity, alignment: .leading)
        case .statusFail(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(p.muted)
                if let onRetry {
                    Button("Retry", action: onRetry)
                        .tint(p.accent)
                }
            }
        case .recovery(let message):
            VStack(alignment: .leading, spacing: 6) {
                Text(message)
                    .font(.caption2)
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
    let now: Date
    let action: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(isAccent ? p.accentForeground : p.foreground)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(isAccent ? p.accentForeground.opacity(0.85) : p.muted)
            }
            .frame(maxWidth: .infinity, minHeight: BabyTokens.minHit, alignment: .leading)
            .padding(10)
            .background(isAccent ? p.accent : p.surface)
            .clipShape(RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: BabyTokens.outerRadius, style: .continuous)
                    .stroke(p.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var isAccent: Bool {
        if case .running = phase { return true }
        if case .done = phase { return true }
        return false
    }

    private var title: String {
        switch phase {
        case .idle:
            return side.rawValue
        case .running:
            return "\(side == .nap ? "Nap" : side.rawValue) - Tap to stop"
        case .done:
            return "Done"
        }
    }

    private var subtitle: String {
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

struct MlChipRow: View {
    @Environment(\.colorScheme) private var scheme
    let mls: [Int]
    let selected: Int?
    let doneMl: Int?
    let onSelect: (Int) -> Void
    let onCustom: () -> Void

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 52), spacing: 6)], spacing: 6) {
            ForEach(mls, id: \.self) { ml in
                let selectedNow = selected == ml || doneMl == ml
                Button("\(ml)") {
                    onSelect(ml)
                }
                .font(.headline.weight(.bold))
                .foregroundStyle(selectedNow ? p.accentForeground : p.foreground)
                .frame(minHeight: BabyTokens.minHit)
                .frame(maxWidth: .infinity)
                .background(selectedNow ? p.accent : p.surface)
                .clipShape(RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: BabyTokens.nestedRadius, style: .continuous)
                        .stroke(p.hairline, lineWidth: 1)
                )
                .buttonStyle(.plain)
            }
            Button("Custom", action: onCustom)
                .font(.caption.weight(.semibold))
                .foregroundStyle(p.foreground)
                .frame(minHeight: BabyTokens.minHit)
                .frame(maxWidth: .infinity)
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
    @Environment(\.colorScheme) private var scheme
    let selected: DiaperKind?
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
                let on = selected == kind || done == kind
                Button {
                    onSelect(kind)
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: kind.systemImage)
                        Text(kind.rawValue)
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(on ? p.accentForeground : p.foreground)
                    .frame(maxWidth: .infinity, minHeight: BabyTokens.minHit)
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
