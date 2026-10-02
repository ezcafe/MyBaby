import Foundation

enum BabyCareWidgetTimeline {
    /// Next rebuild policy (verify-only; do not thrash WidgetKit):
    /// while a timer runs keep a long horizon (digits use Text.timer);
    /// else at next-feed due / overdue boundary, else 15 min.
    static func nextUpdate(for snapshot: BabyHomeStatusSnapshot, now: Date = .now) -> Date {
        if snapshot.openNapStartedAt != nil || snapshot.runningTimerStartedAt != nil {
            return now.addingTimeInterval(15 * 60)
        }
        if let overdue = snapshot.feedOverdueSeconds, overdue <= 0,
           let next = snapshot.nextFeedInSeconds, next > 0
        {
            return now.addingTimeInterval(next)
        }
        if let next = snapshot.nextFeedInSeconds, next > 0 {
            return now.addingTimeInterval(next)
        }
        return now.addingTimeInterval(15 * 60)
    }
}
