import Foundation

/// Port of my-apps `buildBabyBottleChipMls` — history first, then snaps.
/// Watch UI uses `limit: 3` (+ Custom in the view).
enum BabyBottleChipMls {
    static let noBirthSnaps: [Int] = [60, 90, 120]

    static func build(
        recentBottleMl: [Int],
        snaps: [Int],
        limit: Int = 3
    ) -> [Int] {
        var out: [Int] = []
        var seen = Set<Int>()

        func push(_ ml: Int) {
            guard ml > 0, !seen.contains(ml), out.count < limit else { return }
            seen.insert(ml)
            out.append(ml)
        }

        for ml in recentBottleMl { push(ml) }
        for ml in snaps { push(ml) }
        return out
    }
}

/// Local quick-care side effects (mirror my-apps plan + server endNap rules).
/// Pump family does **not** auto-end open nap; non-pump does.
enum CareQuickAction: Equatable {
    case breast
    case bottle
    case diaper
    case sleep
    case pumpTimer
    case pumpAmount
}

struct CareSideEffectFlags: Equatable {
    var endOpenNap: Bool
    var stopBreast: Bool

    static let none = CareSideEffectFlags(endOpenNap: false, stopBreast: false)
}

enum CareSideEffects {
    static func flags(
        for action: CareQuickAction,
        napOpen: Bool,
        breastRunning: Bool
    ) -> CareSideEffectFlags {
        let pumpFamily = action == .pumpTimer || action == .pumpAmount
        if pumpFamily {
            return .none
        }
        var endNap = false
        var stopBreast = false
        // Sleep owns nap via advanceNap — never endOpenNap from sleep flags.
        if napOpen, action != .sleep {
            endNap = true
        }
        switch action {
        case .bottle, .diaper, .sleep:
            if breastRunning { stopBreast = true }
        case .breast, .pumpTimer, .pumpAmount:
            break
        }
        return CareSideEffectFlags(endOpenNap: endNap, stopBreast: stopBreast)
    }
}
