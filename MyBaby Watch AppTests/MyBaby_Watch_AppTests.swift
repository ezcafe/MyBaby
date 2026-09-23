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

    @Test func lastCareLeadIncludesAgeMonths() {
        #expect(BabyHomeStatusSnapshot.lastCareLead(ageDays: 120) == "Last care · 4 months")
        #expect(BabyHomeStatusSnapshot.sampleNextFeed().lastCareHeaderLead == "Last care · 4 months")
        #expect(BabyHomeStatusSnapshot.lastCareLead(ageDays: 10) == "Last care · 10 days")
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

    @Test func deepLinkBottleMaps() {
        let url = URL(string: "mybaby://home?page=bottle")!
        #expect(BabyHomeDeepLink.page(from: url) == .bottle)
    }

    @Test func deepLinkFeedMaps() {
        let url = URL(string: "mybaby://home?page=feed")!
        #expect(BabyHomeDeepLink.page(from: url) == .feed)
    }

    @Test func deepLinkUnknownFallsBack() {
        let url = URL(string: "mybaby://home?page=unknown")!
        #expect(BabyHomeDeepLink.page(from: url) == .feed)
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
        let feedKind = BabyCarePrimarySignal.resolve(.sampleNextFeed())
        #expect(BabyCarePrimarySignal.deepLinkPage(for: feedKind) == .feed)
    }

    @Test func pageOrderIsFeedBottleSleepDiaperPumpPumpAmountLastCare() {
        #expect(BabyHomePage.allCases.map(\.rawValue) == [0, 1, 2, 3, 4, 5, 6])
        #expect(BabyHomePage.feed.queryValue == "feed")
        #expect(BabyHomePage.bottle.queryValue == "bottle")
        #expect(BabyHomePage.pump.queryValue == "pump")
        #expect(BabyHomePage.pumpAmount.queryValue == "pump-amount")
        #expect(BabyHomePage.lastCare.queryValue == "status")
    }

    @Test func pageMountKeepsSelectedAndNeighborsOnly() {
        #expect(BabyHomePage.shouldMount(.feed, selected: .feed))
        #expect(BabyHomePage.shouldMount(.bottle, selected: .feed))
        #expect(!BabyHomePage.shouldMount(.sleep, selected: .feed))
        #expect(BabyHomePage.shouldMount(.sleep, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.diaper, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.pump, selected: .diaper))
        #expect(!BabyHomePage.shouldMount(.feed, selected: .diaper))
        #expect(!BabyHomePage.shouldMount(.lastCare, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.pumpAmount, selected: .lastCare))
        #expect(!BabyHomePage.shouldMount(.pump, selected: .lastCare))
    }

    @Test func deepLinkPumpAmountMaps() {
        let url = URL(string: "mybaby://home?page=pump-amount")!
        #expect(BabyHomeDeepLink.page(from: url) == .pumpAmount)
    }

    // MARK: - Chip builder (web buildBabyBottleChipMls, Watch limit 3)

    @Test func chipBuilderHistoryFirstLimit3() {
        #expect(
            BabyBottleChipMls.build(
                recentBottleMl: [90],
                snaps: [60, 70, 80, 90],
                limit: 3
            ) == [90, 60, 70]
        )
    }

    @Test func chipBuilderEmptyHistoryNoBirthSnaps() {
        #expect(
            BabyBottleChipMls.build(
                recentBottleMl: [],
                snaps: BabyBottleChipMls.noBirthSnaps,
                limit: 3
            ) == [60, 90, 120]
        )
    }

    @Test func sampleBottleChipsAreThree() {
        #expect(BabyHomeStatusSnapshot.sampleNextFeed().bottleChipMls.count == 3)
    }

    // MARK: - Care side effects (web quick-care parity)

    @Test func sideEffectsBreastEndsOpenNap() {
        let f = CareSideEffects.flags(for: .breast, napOpen: true, breastRunning: false)
        #expect(f.endOpenNap)
        #expect(!f.stopBreast)
    }

    @Test func sideEffectsBottleEndsNapAndStopsBreast() {
        let f = CareSideEffects.flags(for: .bottle, napOpen: true, breastRunning: true)
        #expect(f.endOpenNap)
        #expect(f.stopBreast)
    }

    @Test func sideEffectsDiaperEndsNapAndStopsBreast() {
        let f = CareSideEffects.flags(for: .diaper, napOpen: true, breastRunning: true)
        #expect(f.endOpenNap)
        #expect(f.stopBreast)
    }

    @Test func sideEffectsPumpTimerLeavesNapAndBreast() {
        let f = CareSideEffects.flags(for: .pumpTimer, napOpen: true, breastRunning: true)
        #expect(!f.endOpenNap)
        #expect(!f.stopBreast)
    }

    @Test func sideEffectsPumpAmountLeavesNapAndBreast() {
        let f = CareSideEffects.flags(for: .pumpAmount, napOpen: true, breastRunning: true)
        #expect(!f.endOpenNap)
        #expect(!f.stopBreast)
    }

    @Test func sideEffectsSleepDoesNotEndNapButStopsBreast() {
        let f = CareSideEffects.flags(for: .sleep, napOpen: true, breastRunning: true)
        #expect(!f.endOpenNap)
        #expect(f.stopBreast)
    }

    @Test func sideEffectsSleepIdleBreastNoFlags() {
        let f = CareSideEffects.flags(for: .sleep, napOpen: true, breastRunning: false)
        #expect(!f.endOpenNap)
        #expect(!f.stopBreast)
    }

    @Test @MainActor func modelBottleClearsOpenNap() {
        let model = BabyHomeStatusModel(snapshot: .sampleOpenNap())
        #expect(model.snapshot.openNapStartedAt != nil)
        model.selectBottle(ml: 90)
        #expect(model.snapshot.openNapStartedAt == nil)
    }

    @Test @MainActor func modelPumpKeepsOpenNap() {
        let model = BabyHomeStatusModel(snapshot: .sampleOpenNap())
        let started = model.snapshot.openNapStartedAt
        model.selectPump(ml: 60)
        #expect(model.snapshot.openNapStartedAt == started)
        if case .running = model.nap {
            // still running
        } else {
            Issue.record("Expected nap still running after pump amount")
        }
    }

    @Test @MainActor func modelBreastStartClearsOpenNap() {
        let model = BabyHomeStatusModel(snapshot: .sampleOpenNap())
        model.toggleTimed(.breastLeft)
        #expect(model.snapshot.openNapStartedAt == nil)
        #expect(model.nap == .idle)
        if case .running = model.breastLeft {
            // ok
        } else {
            Issue.record("Expected breast left running")
        }
    }

    @Test @MainActor func modelBottleStopsBreastToIdle() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.selectBottle(ml: 90)
        #expect(model.breastLeft == .idle)
        #expect(model.bottleDoneMl == 90)
        #expect(model.selectedBottleMl == nil)
    }

    @Test @MainActor func modelNapSelfStopGoesDone() {
        let model = BabyHomeStatusModel(snapshot: .sampleOpenNap())
        #expect({
            if case .running = model.nap { return true }
            return false
        }())
        model.toggleTimed(.nap)
        #expect(model.nap == .done)
        #expect(model.snapshot.openNapStartedAt == nil)
    }

    @Test @MainActor func modelPumpAmountLeavesBreastRunning() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.selectPump(ml: 60)
        if case .running = model.breastLeft {
            // ok
        } else {
            Issue.record("Expected breast still running after pump amount")
        }
        #expect(model.pumpDoneMl == 60)
        #expect(model.selectedPumpMl == nil)
    }

    @Test @MainActor func modelBottleLeavesPumpRunning() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.pumpLeft)
        model.selectBottle(ml: 90)
        if case .running = model.pumpLeft {
            // ok
        } else {
            Issue.record("Expected pump still running after bottle")
        }
    }

    @Test @MainActor func modelPumpBothClearsPumpLeft() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.pumpLeft)
        model.toggleTimed(.pumpBoth)
        #expect(model.pumpLeft == .idle)
        if case .running = model.pumpBoth {
            // ok
        } else {
            Issue.record("Expected pump both running")
        }
    }

    @Test @MainActor func modelPumpLeftClearsPumpBoth() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.pumpBoth)
        model.toggleTimed(.pumpLeft)
        #expect(model.pumpBoth == .idle)
        if case .running = model.pumpLeft {
            // ok
        } else {
            Issue.record("Expected pump left running")
        }
    }

    @Test @MainActor func modelDiaperFlashOnlyNoLastingSelected() {
        let model = BabyHomeStatusModel()
        model.selectDiaper(.wet)
        #expect(model.diaperDoneKind == .wet)
        #expect(model.selectedDiaperKind == nil)
    }

    @Test @MainActor func modelDiaperStopsBreastToIdle() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastRight)
        model.selectDiaper(.wet)
        #expect(model.breastRight == .idle)
        #expect(model.diaperDoneKind == .wet)
    }

    @Test @MainActor func modelNapStartStopsBreastToIdle() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.toggleTimed(.nap)
        #expect(model.breastLeft == .idle)
        if case .running = model.nap {
            // ok
        } else {
            Issue.record("Expected nap running")
        }
    }

    @Test @MainActor func modelBreastSwitchClearsOtherSide() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.toggleTimed(.breastRight)
        #expect(model.breastLeft == .idle)
        if case .running = model.breastRight {
            // ok
        } else {
            Issue.record("Expected breast right running")
        }
    }

    @Test @MainActor func modelSelfStopBreastGoesDone() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.toggleTimed(.breastLeft)
        #expect(model.breastLeft == .done)
    }

    @Test @MainActor func modelBottleClearsOpenNapToIdle() {
        let model = BabyHomeStatusModel(snapshot: .sampleOpenNap())
        model.selectBottle(ml: 90)
        #expect(model.snapshot.openNapStartedAt == nil)
        #expect(model.nap == .idle)
    }

    @Test func timedChipRunningTitleHasNoTapToStop() {
        #expect(TimedChipSide.breastLeft.runningTitle == "Left")
        #expect(TimedChipSide.nap.runningTitle == "Nap")
        #expect(!TimedChipSide.breastLeft.runningTitle.localizedCaseInsensitiveContains("tap to stop"))
        #expect(TimedChipSide.breastLeft.idleSubtitle == "Tap to start")
    }

    @Test func customMlPickerShowsThreeRows() {
        #expect(CustomMlPicker.visibleRowCount == 3)
    }

    @Test func lastCareSampleCopyIsShortOneLine() {
        let s = BabyHomeStatusSnapshot.sampleNextFeed()
        #expect(s.lastFeed.sentence == "Bottle 120 ml · 25m")
        #expect(s.lastDiaper.sentence == "Wet · 1h")
        #expect(s.lastDiaper.iconSystemName == "leaf.fill")
        #expect(s.lastFeed.iconSystemName == "waterbottle.fill")
        #expect(s.lastNap.sentence == "No nap yet")
        #expect(s.lastPump.sentence == "No pump yet")
    }

    @Test func diaperIconTitleSpacingIsTight() {
        #expect(DiaperKindGrid.iconTitleSpacing == 0)
        #expect(DiaperKindGrid.titleFontSize == 10)
        #expect(DiaperKindGrid.chipHeight == BabyTokens.careChipHeight)
    }

    @Test func timedCareChipMatchesAmountChipHeight() {
        #expect(BabyTokens.careChipHeight == BabyTokens.minHit)
        #expect(DiaperKindGrid.chipHeight == BabyTokens.careChipHeight)
    }

    @Test func timedChipPumpBothTitle() {
        #expect(TimedChipSide.pumpBoth.title == "Both")
        #expect(TimedChipSide.pumpBoth.runningTitle == "Both")
    }

    @Test func timedChipPumpSidesAreLeftRight() {
        #expect(TimedChipSide.pumpLeft.title == "Left")
        #expect(TimedChipSide.pumpRight.title == "Right")
        #expect(TimedChipSide.pumpLeft.runningTitle == "Left")
        #expect(TimedChipSide.pumpRight.runningTitle == "Right")
    }

    // MARK: - Memory hygiene (cancel + tick gate)

    @Test func careTimerTicksOnlyWhenRunningSelectedAndActive() {
        #expect(CareTimerTicks.shouldTick(running: true, pageSelected: true, sceneActive: true))
        #expect(!CareTimerTicks.shouldTick(running: false, pageSelected: true, sceneActive: true))
        #expect(!CareTimerTicks.shouldTick(running: true, pageSelected: false, sceneActive: true))
        #expect(!CareTimerTicks.shouldTick(running: true, pageSelected: true, sceneActive: false))
    }

    @Test @MainActor func modelSecondDoneFlashCancelsPriorClearTask() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.breastLeft)
        model.toggleTimed(.breastLeft)
        #expect(model.breastLeft == .done)
        let first = model.clearDoneTask
        #expect(first != nil)

        model.toggleTimed(.breastRight)
        model.toggleTimed(.breastRight)
        #expect(model.breastRight == .done)
        #expect(first?.isCancelled == true)
        #expect(model.clearDoneTask != nil)
    }

    @Test @MainActor func modelAmountFlashCancelsPriorSideClearTask() {
        let model = BabyHomeStatusModel()
        model.toggleTimed(.nap)
        model.toggleTimed(.nap)
        #expect(model.nap == .done)
        let first = model.clearDoneTask
        #expect(first != nil)

        model.selectBottle(ml: 90)
        #expect(first?.isCancelled == true)
        #expect(model.clearDoneTask != nil)
        #expect(model.bottleDoneMl == 90)
    }
}
