import Foundation

/// Watch mirror of my-apps `lib/baby-diaper-detail.ts` + quick-plan helpers.

enum DiaperDetailColor: String, CaseIterable, Identifiable {
    case yellow
    case brown
    case green
    case black
    case white_pale
    case red_bloody

    var id: String { rawValue }

    var label: String {
        switch self {
        case .yellow: return "Yellow"
        case .brown: return "Brown"
        case .green: return "Green"
        case .black: return "Black"
        case .white_pale: return "White"
        case .red_bloody: return "Red"
        }
    }

    var isRedFlag: Bool {
        self == .white_pale || self == .red_bloody
    }
}

enum DiaperDetailTexture: String, CaseIterable, Identifiable {
    case soft
    case seedy
    case mushy
    case watery
    case hard
    case formed

    var id: String { rawValue }

    var label: String {
        switch self {
        case .soft: return "Soft"
        case .seedy: return "Seedy"
        case .mushy: return "Mushy"
        case .watery: return "Watery"
        case .hard: return "Hard"
        case .formed: return "Formed"
        }
    }

    var needsCaution: Bool {
        self == .watery || self == .hard
    }
}

enum DiaperDetailAmount: String, CaseIterable, Identifiable {
    case smear
    case medium
    case blowout

    var id: String { rawValue }

    var label: String {
        switch self {
        case .smear: return "Smear"
        case .medium: return "Medium"
        case .blowout: return "Blowout"
        }
    }

    static var `default`: DiaperDetailAmount { .medium }
}

struct DiaperSheetDraft: Equatable {
    var color: DiaperDetailColor?
    var texture: DiaperDetailTexture?
    var amount: DiaperDetailAmount

    static func openSheetDefaults() -> DiaperSheetDraft {
        DiaperSheetDraft(color: nil, texture: nil, amount: .default)
    }
}

enum DiaperKindTapPlan: Equatable {
    case instantSave(DiaperKind)
    case openSheet(DiaperKind, DiaperSheetDraft)
}

/// S1 parity with my-apps `planBabyDiaperKindTap`.
func planDiaperKindTap(_ kind: DiaperKind) -> DiaperKindTapPlan {
    switch kind {
    case .wet, .dry:
        return .instantSave(kind)
    case .poop, .mixed:
        return .openSheet(kind, .openSheetDefaults())
    }
}

/// Builds live `babyQuickCare` action dict (mirrors `babyDiaperSheetSaveMutation`).
func diaperSheetSaveAction(kind: DiaperKind, draft: DiaperSheetDraft) -> [String: Any] {
    var action: [String: Any] = [
        "kind": "DIAPER",
        "diaperKind": kind.apiValue,
        "diaperAmount": draft.amount.rawValue,
    ]
    if let color = draft.color {
        action["diaperColor"] = color.rawValue
    }
    if let texture = draft.texture {
        action["diaperTexture"] = texture.rawValue
    }
    return action
}

func toggleOptionalDiaperChip<T: Equatable>(_ current: T?, next: T) -> T? {
    current == next ? nil : next
}
