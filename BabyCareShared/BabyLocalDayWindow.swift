import Foundation

struct BabyLocalDayWindow: Equatable, Sendable {
    var dayFrom: String
    var dayTo: String
    var dayKey: String

    /// Half-open local calendar day: midnight → next midnight (ISO-8601 with offset).
    static func make(now: Date = .now, calendar: Calendar = .current) -> BabyLocalDayWindow {
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(86_400)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = calendar.timeZone
        let from = formatter.string(from: start)
        let to = formatter.string(from: end)
        let keyFormatter = DateFormatter()
        keyFormatter.calendar = calendar
        keyFormatter.timeZone = calendar.timeZone
        keyFormatter.dateFormat = "yyyy-MM-dd"
        return BabyLocalDayWindow(
            dayFrom: from,
            dayTo: to,
            dayKey: keyFormatter.string(from: start)
        )
    }
}
