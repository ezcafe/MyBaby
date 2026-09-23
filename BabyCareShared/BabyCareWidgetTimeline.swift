import Foundation

enum BabyCareWidgetTimeline {
    /// Next refresh: ~1 min while napping, else at next-feed due, else 15 min.
    static func nextUpdate(for snapshot: BabyHomeStatusSnapshot, now: Date = .now) -> Date {
        if snapshot.openNapStartedAt != nil {
            return now.addingTimeInterval(60)
        }
        if let next = snapshot.nextFeedInSeconds, next > 0 {
            return now.addingTimeInterval(next)
        }
        return now.addingTimeInterval(15 * 60)
    }
}
