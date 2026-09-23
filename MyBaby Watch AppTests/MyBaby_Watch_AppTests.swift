import Foundation
import Testing
@testable import MyBaby_Watch_App

struct BabyHomeStatusTests {
    @Test func primarySignalPrefersOpenNap() {
        let snap = BabyHomeStatusSnapshot.sampleOpenNap()
        let kind = BabyCarePrimarySignal.resolve(snap)
        guard case .openNap = kind else {
            Issue.record("Expected openNap, got \(kind)")
            return
        }
    }

    @Test func overdueBeatsNextFeed() {
        var snap = BabyHomeStatusSnapshot.sampleNextFeed()
        snap.openNapStartedAt = nil
        snap.nextFeedInSeconds = 600
        snap.feedOverdueSeconds = 300
        let kind = BabyCarePrimarySignal.resolve(snap)
        guard case .overdueFeed = kind else {
            Issue.record("Expected overdueFeed, got \(kind)")
            return
        }
    }

    @Test func ageTitleUsesDaysUnderOneMonth() {
        #expect(BabyHomeStatusSnapshot.ageTitle(ageDays: 10) == "Baby Care · 10 days")
        #expect(BabyHomeStatusSnapshot.ageTitle(ageDays: 1) == "Baby Care · 1 day")
    }

    @Test func ageTitleUsesMonths() {
        #expect(BabyHomeStatusSnapshot.ageTitle(ageDays: 120) == "Baby Care · 4 months")
    }

    @Test func footerRecoveryBeatsTip() {
        let content = CareFooterResolver.resolve(
            recovery: "Could not confirm. Retry / Discard",
            statusFail: "Status failed",
            tip: "About 6–8 feeds a day."
        )
        guard case .recovery = content else {
            Issue.record("Expected recovery, got \(content)")
            return
        }
    }

    @Test func timedChipStateMachine() {
        var phase: TimedChipPhase = .idle
        let start = Date()
        phase = .running(startedAt: start)
        #expect({
            if case .running = phase { return true }
            return false
        }())
        phase = .done
        #expect(phase == .done)
        phase = .idle
        #expect(phase == .idle)
    }

    @Test func deepLinkSleepMaps() {
        let url = URL(string: "mybaby://home?page=sleep")!
        #expect(BabyHomeDeepLink.page(from: url) == .sleep)
    }

    @Test func deepLinkUnknownFallsBack() {
        let url = URL(string: "mybaby://home?page=unknown")!
        #expect(BabyHomeDeepLink.page(from: url) == .feedBottle)
    }

    @Test func diaperPoopMapsToDirty() {
        #expect(DiaperKind.poop.apiValue == "dirty")
    }

    @Test func timelineRefreshUsesNapOrDue() {
        let nap = BabyHomeStatusSnapshot.sampleOpenNap()
        let next = BabyCareWidgetTimeline.nextUpdate(for: nap, now: Date(timeIntervalSince1970: 1_000_000))
        #expect(next.timeIntervalSince1970 == 1_000_000 + 60)

        let feed = BabyHomeStatusSnapshot.sampleNextFeed()
        let due = BabyCareWidgetTimeline.nextUpdate(for: feed, now: Date(timeIntervalSince1970: 1_000_000))
        #expect(due.timeIntervalSince1970 == 1_000_000 + 12 * 60)
    }

    @Test func primarySignalDeepLinkMatchesPageIds() {
        let napKind = BabyCarePrimarySignal.resolve(.sampleOpenNap())
        #expect(BabyCarePrimarySignal.deepLinkPage(for: napKind) == .sleep)
        #expect(BabyHomeDeepLink.url(page: .sleep).absoluteString.contains("page=sleep"))
    }
}
