import Foundation

/// Essay care-guide stage cuts — mirror my-apps `babyCareGuideStageForAge`.
enum CareGuideStage: String, Equatable, Sendable {
    case newborn
    case m1_3
    case m3_6
    case m6_12
    case m12_24

    static func forAgeDays(_ ageDays: Int) -> CareGuideStage {
        if ageDays <= 30 { return .newborn }
        if ageDays <= 90 { return .m1_3 }
        if ageDays <= 182 { return .m3_6 }
        if ageDays <= 364 { return .m6_12 }
        return .m12_24
    }
}

/// Bottle ml band from essay — mirror my-apps FEED_GUIDE_BANDS / ESSAY_BOTTLE_ML_FIXTURES.
struct CareGuideBottleBand: Equatable, Sendable {
    var mlMin: Int
    var mlMax: Int
    var feedsMin: Int
    var feedsMax: Int

    var midMl: Int {
        let mid = Double(mlMin + mlMax) / 2
        let rounded = Int((mid / 10).rounded()) * 10
        return min(mlMax, max(mlMin, rounded))
    }

    /// Cross-app fixture snaps: min, mid, max (deduped).
    var snaps: [Int] {
        var out: [Int] = []
        for ml in [mlMin, midMl, mlMax] where !out.contains(ml) {
            out.append(ml)
        }
        return Array(out.prefix(3))
    }

    static func forAgeDays(_ ageDays: Int) -> CareGuideBottleBand {
        if ageDays <= 30 {
            return .init(mlMin: 30, mlMax: 60, feedsMin: 7, feedsMax: 8)
        }
        if ageDays <= 60 {
            return .init(mlMin: 90, mlMax: 120, feedsMin: 6, feedsMax: 8)
        }
        if ageDays <= 90 {
            return .init(mlMin: 120, mlMax: 150, feedsMin: 6, feedsMax: 8)
        }
        if ageDays <= 182 {
            return .init(mlMin: 150, mlMax: 210, feedsMin: 5, feedsMax: 6)
        }
        if ageDays <= 364 {
            return .init(mlMin: 180, mlMax: 240, feedsMin: 3, feedsMax: 4)
        }
        return .init(mlMin: 120, mlMax: 180, feedsMin: 2, feedsMax: 3)
    }
}

/// Short page tips EN/VI — essay-aligned (system locale; `vi` → Vietnamese).
enum CareGuideTips {
    private static let en: [String: String] = [
        "breast.newborn": "About 8–12 feeds a day.",
        "breast.m1_3": "About 6–8 feeds a day.",
        "breast.m3_6": "About 5–6 feeds a day.",
        "breast.milkDaily": "About 350–500 ml of milk a day.",
        "bottle.ml": "About %d ml each time.",
        "sleep.newborn": "About 16–18 hours of sleep a day.",
        "sleep.m1_3": "About 14–16 hours of sleep a day.",
        "sleep.m3_6": "About 14–15 hours of sleep a day.",
        "sleep.m6_12": "About 12–14 hours of sleep a day.",
        "sleep.m12_24": "About 11–14 hours of sleep a day.",
        "diaper.newborn": "Change every 2–3 hours; Newborn size (<5kg).",
        "diaper.m1_3": "Tape diapers Size S (4–8kg).",
        "diaper.m3_6": "Pants diapers Size M (6–11kg).",
        "diaper.m6_12": "Pants diapers Size L (9–14kg).",
        "diaper.m12_24": "Pants Size XL/XXL (>12kg).",
        "pump.newborn": "Pump every 2–3 hours (8–10 times/day).",
        "pump.m1_3": "About 90–150 ml/session; 6–8 times/day.",
        "pump.m3_6": "About 120–180 ml/session; 4–6 times/day.",
        "pump.m6_12": "About 150–220 ml/session; 3–4 times/day.",
        "pump.m12_24": "Pump 1–2 times/day if still pumping.",
    ]

    private static let vi: [String: String] = [
        "breast.newborn": "Khoảng 8–12 lần bú mỗi ngày.",
        "breast.m1_3": "Khoảng 6–8 lần bú mỗi ngày.",
        "breast.m3_6": "Khoảng 5–6 lần bú mỗi ngày.",
        "breast.milkDaily": "Khoảng 350–500 ml sữa mỗi ngày.",
        "bottle.ml": "Khoảng %d ml mỗi lần.",
        "sleep.newborn": "Khoảng 16–18 giờ ngủ mỗi ngày.",
        "sleep.m1_3": "Khoảng 14–16 giờ ngủ mỗi ngày.",
        "sleep.m3_6": "Khoảng 14–15 giờ ngủ mỗi ngày.",
        "sleep.m6_12": "Khoảng 12–14 giờ ngủ mỗi ngày.",
        "sleep.m12_24": "Khoảng 11–14 giờ ngủ mỗi ngày.",
        "diaper.newborn": "Thay mỗi 2–3 tiếng; size Newborn (<5kg).",
        "diaper.m1_3": "Tã dán Size S (4–8kg).",
        "diaper.m3_6": "Tã quần Size M (6–11kg).",
        "diaper.m6_12": "Tã quần Size L (9–14kg).",
        "diaper.m12_24": "Tã quần Size XL/XXL (>12kg).",
        "pump.newborn": "Hút mỗi 2–3 tiếng (8–10 lần/ngày).",
        "pump.m1_3": "Khoảng 90–150 ml/lần; 6–8 lần/ngày.",
        "pump.m3_6": "Khoảng 120–180 ml/lần; 4–6 lần/ngày.",
        "pump.m6_12": "Khoảng 150–220 ml/lần; 3–4 lần/ngày.",
        "pump.m12_24": "Hút 1–2 lần/ngày nếu còn duy trì.",
    ]

    private static func isVietnamese(_ locale: Locale) -> Bool {
        if #available(watchOS 16.0, *) {
            return locale.language.languageCode?.identifier == "vi"
        }
        return locale.identifier.lowercased().hasPrefix("vi")
    }

    private static func text(_ key: String, locale: Locale) -> String {
        if isVietnamese(locale) { return vi[key] ?? en[key]! }
        return en[key]!
    }

    static func breastFeedsTip(ageDays: Int, locale: Locale = .current) -> String {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return text("breast.newborn", locale: locale)
        case .m1_3: return text("breast.m1_3", locale: locale)
        case .m3_6: return text("breast.m3_6", locale: locale)
        case .m6_12, .m12_24: return text("breast.milkDaily", locale: locale)
        }
    }

    static func bottleTip(ageDays: Int, locale: Locale = .current) -> String {
        let band = CareGuideBottleBand.forAgeDays(ageDays)
        let format = text("bottle.ml", locale: locale)
        return String(format: format, locale: locale, band.midMl)
    }

    static func sleepTip(ageDays: Int, locale: Locale = .current) -> String {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return text("sleep.newborn", locale: locale)
        case .m1_3: return text("sleep.m1_3", locale: locale)
        case .m3_6: return text("sleep.m3_6", locale: locale)
        case .m6_12: return text("sleep.m6_12", locale: locale)
        case .m12_24: return text("sleep.m12_24", locale: locale)
        }
    }

    static func diaperTip(ageDays: Int, locale: Locale = .current) -> String {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return text("diaper.newborn", locale: locale)
        case .m1_3: return text("diaper.m1_3", locale: locale)
        case .m3_6: return text("diaper.m3_6", locale: locale)
        case .m6_12: return text("diaper.m6_12", locale: locale)
        case .m12_24: return text("diaper.m12_24", locale: locale)
        }
    }

    static func pumpTip(ageDays: Int, locale: Locale = .current) -> String {
        switch CareGuideStage.forAgeDays(ageDays) {
        case .newborn: return text("pump.newborn", locale: locale)
        case .m1_3: return text("pump.m1_3", locale: locale)
        case .m3_6: return text("pump.m3_6", locale: locale)
        case .m6_12: return text("pump.m6_12", locale: locale)
        case .m12_24: return text("pump.m12_24", locale: locale)
        }
    }
}
