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

    @Test func deepLinkBottleMapsToFeed() {
        let url = URL(string: "mybaby://home?page=bottle")!
        #expect(BabyHomeDeepLink.page(from: url) == .feed)
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
        #expect(next.timeIntervalSince1970 == 1_000_000 + 15 * 60)

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

    @Test func pageOrderIsFeedSleepDiaperPumpLastCare() {
        #expect(BabyHomePage.allCases.map(\.rawValue) == [0, 1, 2, 3, 4])
        #expect(BabyHomePage.feed.queryValue == "feed")
        #expect(BabyHomePage.sleep.queryValue == "sleep")
        #expect(BabyHomePage.diaper.queryValue == "diaper")
        #expect(BabyHomePage.pump.queryValue == "pump")
        #expect(BabyHomePage.lastCare.queryValue == "status")
        #expect(BabyHomePage.fromQuery("settings") == nil)
    }

    @Test func pageMountKeepsSelectedAndNeighborsOnly() {
        #expect(BabyHomePage.shouldMount(.feed, selected: .feed))
        #expect(BabyHomePage.shouldMount(.sleep, selected: .feed))
        #expect(!BabyHomePage.shouldMount(.diaper, selected: .feed))
        #expect(BabyHomePage.shouldMount(.sleep, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.diaper, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.pump, selected: .diaper))
        #expect(!BabyHomePage.shouldMount(.feed, selected: .diaper))
        #expect(!BabyHomePage.shouldMount(.lastCare, selected: .diaper))
        #expect(BabyHomePage.shouldMount(.pump, selected: .lastCare))
        #expect(BabyHomePage.shouldMount(.lastCare, selected: .lastCare))
        #expect(!BabyHomePage.shouldMount(.diaper, selected: .lastCare))
        #expect(!BabyHomePage.shouldMount(.feed, selected: .lastCare))
    }

    @Test func deepLinkPumpAmountMapsToPump() {
        let url = URL(string: "mybaby://home?page=pump-amount")!
        #expect(BabyHomeDeepLink.page(from: url) == .pump)
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

    // MARK: - Essay care guide (cross-app fixtures)

    @Test func careGuideStageCutsMatchWeb() {
        #expect(CareGuideStage.forAgeDays(0) == .newborn)
        #expect(CareGuideStage.forAgeDays(30) == .newborn)
        #expect(CareGuideStage.forAgeDays(31) == .m1_3)
        #expect(CareGuideStage.forAgeDays(90) == .m1_3)
        #expect(CareGuideStage.forAgeDays(91) == .m3_6)
        #expect(CareGuideStage.forAgeDays(182) == .m3_6)
        #expect(CareGuideStage.forAgeDays(183) == .m6_12)
        #expect(CareGuideStage.forAgeDays(364) == .m6_12)
        #expect(CareGuideStage.forAgeDays(365) == .m12_24)
    }

    @Test func essayBottleSnapsMatchCrossAppFixtures() {
        #expect(CareGuideBottleBand.forAgeDays(0).snaps == [30, 50, 60])
        #expect(CareGuideBottleBand.forAgeDays(45).snaps == [90, 110, 120])
        #expect(CareGuideBottleBand.forAgeDays(75).snaps == [120, 140, 150])
        #expect(CareGuideBottleBand.forAgeDays(120).snaps == [150, 180, 210])
        #expect(CareGuideBottleBand.forAgeDays(200).snaps == [180, 210, 240])
        #expect(CareGuideBottleBand.forAgeDays(400).snaps == [120, 150, 180])
    }

    @Test func tipsENAndVIDifferAndMatchEssay() {
        let en = Locale(identifier: "en")
        let vi = Locale(identifier: "vi")
        let sleepEN = CareGuideTips.sleepTip(ageDays: 0, locale: en)
        let sleepVI = CareGuideTips.sleepTip(ageDays: 0, locale: vi)
        #expect(sleepEN.contains("16"))
        #expect(sleepVI.contains("16"))
        #expect(sleepEN != sleepVI)
        #expect(CareGuideTips.diaperTip(ageDays: 120, locale: en).contains("Size M"))
        #expect(CareGuideTips.diaperTip(ageDays: 120, locale: vi).contains("Size M"))
        #expect(CareGuideTips.diaperTip(ageDays: 10, locale: en).contains("\n"))
        #expect(CareGuideTips.pumpTip(ageDays: 45, locale: en).contains("90"))
        #expect(CareGuideTips.breastFeedsTip(ageDays: 0, locale: en).contains("8"))
        #expect(CareGuideTips.breastFeedsTip(ageDays: 0, locale: en).contains("12"))
    }

    @Test func sampleTipsUseEssayStageForAge120() {
        let snap = BabyHomeStatusSnapshot.sampleNextFeed()
        #expect(snap.feedTip.contains("5") || snap.feedTip.contains("6"))
        #expect(snap.bottleChipMls == [150, 180, 210])
        #expect(snap.sleepTip.contains("14"))
        #expect(snap.diaperTip.contains("Size M"))
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
        #expect(
            CareControlLabels.timedSubtitle(
                side: .breastLeft,
                phase: .idle,
                isFailed: false,
                elapsed: ""
            ) == ""
        )
    }

    @Test func customMlPickerShowsThreeRows() {
        #expect(CustomMlPicker.visibleRowCount == 3)
    }

    @Test func customMlPickerTitleIsCentered() {
        #expect(CustomMlPicker.titleIsCentered)
    }

    @Test func bottleAndPumpAmountSheetTitlesAreCentered() {
        #expect(BottleAmountSheet.titleIsCentered)
        #expect(PumpAmountSheet.titleIsCentered)
    }

    @Test func planDiaperKindTapWetDryIsInstant() {
        guard case .instantSave(let wet) = planDiaperKindTap(.wet) else {
            Issue.record("Expected instantSave for wet")
            return
        }
        #expect(wet == .wet)
        guard case .instantSave(let dry) = planDiaperKindTap(.dry) else {
            Issue.record("Expected instantSave for dry")
            return
        }
        #expect(dry == .dry)
    }

    @Test func planDiaperKindTapPoopMixedOpensSheetWithMedium() {
        guard case .openSheet(let poop, let poopDraft) = planDiaperKindTap(.poop) else {
            Issue.record("Expected openSheet for poop")
            return
        }
        #expect(poop == .poop)
        #expect(poopDraft.amount == .medium)
        #expect(poopDraft.color == nil)
        #expect(poopDraft.texture == nil)

        guard case .openSheet(let mixed, let mixedDraft) = planDiaperKindTap(.mixed) else {
            Issue.record("Expected openSheet for mixed")
            return
        }
        #expect(mixed == .mixed)
        #expect(mixedDraft.amount == .medium)
        #expect(mixedDraft.color == nil)
        #expect(mixedDraft.texture == nil)
    }

    @Test func diaperSheetSaveActionOmitsNilColorTexture() {
        let action = diaperSheetSaveAction(
            kind: .poop,
            draft: DiaperSheetDraft(color: nil, texture: .watery, amount: .medium)
        )
        #expect(action["kind"] as? String == "DIAPER")
        #expect(action["diaperKind"] as? String == "dirty")
        #expect(action["diaperTexture"] as? String == "watery")
        #expect(action["diaperAmount"] as? String == "medium")
        #expect(action["diaperColor"] == nil)
    }

    @Test func diaperSheetSaveActionMapsPoopToDirty() {
        let action = diaperSheetSaveAction(
            kind: .poop,
            draft: DiaperSheetDraft(color: .yellow, texture: nil, amount: .smear)
        )
        #expect(action["diaperKind"] as? String == "dirty")
        #expect(action["diaperColor"] as? String == "yellow")
        #expect(action["diaperAmount"] as? String == "smear")
    }

    @Test func diaperColorRedFlagAndTextureCaution() {
        #expect(DiaperDetailColor.red_bloody.isRedFlag)
        #expect(DiaperDetailColor.white_pale.isRedFlag)
        #expect(!DiaperDetailColor.yellow.isRedFlag)
        #expect(DiaperDetailTexture.watery.needsCaution)
        #expect(DiaperDetailTexture.hard.needsCaution)
        #expect(!DiaperDetailTexture.soft.needsCaution)
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
        #expect(DiaperKindGrid.chipHeight == BabyTokens.careChipHeight)
    }

    @Test func timedCareChipMatchesAmountChipHeight() {
        #expect(BabyTokens.careChipHeight == BabyTokens.minHit)
        #expect(DiaperKindGrid.chipHeight == BabyTokens.careChipHeight)
    }

    @Test func phoneCareMetricsAreRoomierThanWatch() {
        #expect(BabyTokens.careChipHeight(for: .watch) == BabyTokens.minHit)
        #expect(BabyTokens.careChipHeight(for: .phone) == 52)
        #expect(BabyTokens.careChipHeight(for: .phone) > BabyTokens.careChipHeight(for: .watch))
        #expect(BabyTokens.careChromePlatform == .watch)
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

// MARK: - API config + GraphQL (watch-api-base-url)

struct BabyAPIConfigTests {
    @Test func normalizeStripsTrailingSlash() {
        #expect(BabyAPIConfig.normalize("http://127.0.0.1:3000/") == "http://127.0.0.1:3000")
    }

    @Test func graphqlURLAppendsPathOnce() {
        let url = BabyAPIConfig.graphqlURL(base: "https://example.com/")
        #expect(url?.absoluteString == "https://example.com/api/graphql/baby")
    }

    @Test func invalidStringsFailValidation() {
        #expect(!BabyAPIConfig.validate(""))
        #expect(!BabyAPIConfig.validate("/relative"))
        #expect(!BabyAPIConfig.validate("ftp://x"))
        #expect(BabyAPIConfig.validate(BabyAPIConfig.localPreset))
    }

    @Test func httpsExceptLoopbackRejectsCleartextRemote() {
        #expect(BabyAPIConfig.normalize("http://example.com") == nil)
        #expect(!BabyAPIConfig.saveBaseURL("http://evil.example", defaults: UserDefaults(suiteName: "http-reject.\(UUID().uuidString)")!))
        #expect(BabyAPIConfig.normalize("http://127.0.0.1:3000") == "http://127.0.0.1:3000")
        #expect(BabyAPIConfig.normalize("http://localhost:3000") == "http://localhost:3000")
        #expect(BabyAPIConfig.normalize("https://app.example.com") == "https://app.example.com")
    }

    @Test func isLoopbackHostRecognizesLocal() {
        #expect(BabyAPIConfig.isLoopbackHost("127.0.0.1"))
        #expect(BabyAPIConfig.isLoopbackHost("localhost"))
        #expect(BabyAPIConfig.isLoopbackHost("LOCALHOST"))
        #expect(!BabyAPIConfig.isLoopbackHost("example.com"))
        #expect(!BabyAPIConfig.isLoopbackHost(nil))
    }

    @Test func localPresetIsLoopback() {
        #expect(BabyAPIConfig.localPreset == "http://127.0.0.1:3000")
        #expect(BabyAPIConfig.normalize(BabyAPIConfig.productionPreset) != nil)
    }

    @Test func productionPairingOriginIsAbsoluteHTTP() {
        #expect(BabyAPIConfig.validate(BabyAPIConfig.productionPairingOrigin))
    }

    @Test func authGateShowsConnectWhenNeeded() {
        #expect(AuthGate.showsConnect(bypassAuth: false, isConnected: false))
        #expect(!AuthGate.showsConnect(bypassAuth: true, isConnected: false))
        #expect(!AuthGate.showsConnect(bypassAuth: false, isConnected: true))
    }

    @Test func sessionRestoreWhenTokenAndBaseURLExist() {
        #expect(
            BabySessionRestore.shouldRestoreLive(hasToken: true, hasBaseURL: true, isConnected: false)
        )
        #expect(
            !BabySessionRestore.shouldRestoreLive(hasToken: false, hasBaseURL: true, isConnected: false)
        )
        #expect(
            !BabySessionRestore.shouldRestoreLive(hasToken: true, hasBaseURL: false, isConnected: false)
        )
        #expect(
            !BabySessionRestore.shouldRestoreLive(hasToken: true, hasBaseURL: true, isConnected: true)
        )
    }

    @Test func makeLiveClientRequiresTokenAndBaseURL() {
        let store = InMemoryBabyAPITokenStore()
        let suite = "BabySessionRestore.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }

        #expect(BabySessionRestore.makeLiveClientIfPossible(tokenStore: store, defaults: defaults) == nil)

        try? store.save("mny_test")
        #expect(BabySessionRestore.makeLiveClientIfPossible(tokenStore: store, defaults: defaults) == nil)

        #expect(BabyAPIConfig.saveBaseURL("http://127.0.0.1:3000", defaults: defaults))
        let client = BabySessionRestore.makeLiveClientIfPossible(tokenStore: store, defaults: defaults)
        #expect(client != nil)
        #expect(client?.token == "mny_test")
        #expect(client?.baseURLRaw == "http://127.0.0.1:3000")
    }

    @Test func saveBaseURLRoundTrip() {
        let suite = "BabyAPIConfigTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(BabyAPIConfig.saveBaseURL("https://app.example/", defaults: defaults))
        #expect(BabyAPIConfig.loadBaseURL(defaults: defaults) == "https://app.example")
    }

    @Test func resolveHostPresetCloudForLocalURL() {
        #expect(
            BabyAPIConfig.resolveHostPreset(for: BabyAPIConfig.localPreset) == .cloud
        )
        #expect(
            BabyAPIConfig.resolveHostPreset(for: "http://127.0.0.1:3000/") == .cloud
        )
    }

    @Test func resolveHostPresetCloudWhenDistinct() {
        let prod = "https://app.example.com"
        #expect(
            BabyAPIConfig.resolveHostPreset(
                for: prod,
                cloudPreset: prod,
                localPreset: BabyAPIConfig.localPreset
            ) == .cloud
        )
    }

    @Test func resolveHostPresetNoneForEmptyOrOther() {
        #expect(BabyAPIConfig.resolveHostPreset(for: "") == .none)
        #expect(BabyAPIConfig.resolveHostPreset(for: "not-a-url") == .none)
        #expect(
            BabyAPIConfig.resolveHostPreset(for: "https://other.example/") == .none
        )
    }

    @Test func urlFieldVisibleOnlyForCloud() {
        #expect(!ConnectHostURLField.isVisible(selected: .offline))
        #expect(ConnectHostURLField.isVisible(selected: .cloud))
        #expect(!ConnectHostURLField.isVisible(selected: .none))
    }

    @Test func connectDefaultsOfflineAndCloudURL() {
        #expect(ConnectHostURLField.defaultPreset == .offline)
        #expect(ConnectHostURLField.cloudDefaultURL == BabyAPIConfig.localPreset)
        #expect(!ConnectHostURLField.showsPairingFields(selected: .offline))
        #expect(ConnectHostURLField.showsPairingFields(selected: .cloud))
    }

    @Test func selectingCloudResetsDefaultURL() {
        let next = ConnectPresetSelection.apply(.cloud, baseURL: "https://stale.example")
        #expect(next.selected == .cloud)
        #expect(next.baseURL == ConnectHostURLField.cloudDefaultURL)
    }

    @Test func selectingOfflineKeepsURLButHidesFields() {
        let next = ConnectPresetSelection.apply(.offline, baseURL: "https://keep.example")
        #expect(next.selected == .offline)
        #expect(next.baseURL == "https://keep.example")
        #expect(!ConnectHostURLField.isVisible(selected: next.selected))
    }

    /// Plain chips with clear fill are not tappable on watchOS outside the text.
    @Test func connectPresetChipsUseOpaqueFillForHitTesting() {
        #expect(ConnectPresetChipHit.fill(isSelected: true) == .accent)
        #expect(ConnectPresetChipHit.fill(isSelected: false) == .material)
        #expect(ConnectPresetChipHit.fill(isSelected: false) != .clear)
    }
}

struct BabyAPITokenStoreTests {
    @Test func inMemoryRoundTripAndClear() throws {
        let store = InMemoryBabyAPITokenStore()
        #expect(store.load() == nil)
        try store.save("mny_secret")
        #expect(store.load() == "mny_secret")
        try store.clear()
        #expect(store.load() == nil)
    }
}

struct WatchPairRequestBuilderTests {
    @Test func redeemURLAppendsPath() {
        let url = WatchPairRequestBuilder.redeemURL(pairingOriginRaw: "https://app.example.com/")
        #expect(url?.absoluteString == "https://app.example.com/api/watch/pair/redeem")
    }

    @Test func emptyCodePathDoesNotBuildURLForBlankOrigin() {
        #expect(WatchPairRequestBuilder.redeemURL(pairingOriginRaw: "") == nil)
    }
}

struct BabyGraphQLRequestBuilderTests {
    @Test func buildsURLHeadersAndBody() throws {
        let (url, headers, body) = try BabyGraphQLRequestBuilder.makeRequest(
            baseURLRaw: "http://127.0.0.1:3000",
            token: "mny_test",
            document: "{ ping }",
            variablesJSON: #"{"a":1}"#.data(using: .utf8)
        )
        #expect(url.absoluteString == "http://127.0.0.1:3000/api/graphql/baby")
        #expect(headers["Authorization"] == "Bearer mny_test")
        let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
        #expect(json?["query"] as? String == "{ ping }")
        let vars = json?["variables"] as? [String: Any]
        #expect((vars?["a"] as? NSNumber)?.intValue == 1)
    }

    @Test func missingTokenFails() {
        do {
            _ = try BabyGraphQLRequestBuilder.makeRequest(
                baseURLRaw: "http://127.0.0.1:3000",
                token: nil,
                document: "{ ping }",
                variablesJSON: nil
            )
            Issue.record("Expected missingToken")
        } catch let error as BabyGraphQLError {
            #expect(error == .missingToken)
        } catch {
            Issue.record("Wrong error \(error)")
        }
    }

    @Test func clientRequestIdRetrySame() {
        let id = BabyClientRequestId.make()
        #expect(BabyClientRequestId.retrySame(id) == id)
        #expect(id.count == 32)
    }
}

struct BabyLocalDayWindowTests {
    @Test func dayWindowBounds() {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(secondsFromGMT: 7 * 3600)!
        let now = cal.date(from: DateComponents(year: 2026, month: 9, day: 24, hour: 15))!
        let window = BabyLocalDayWindow.make(now: now, calendar: cal)
        #expect(window.dayFrom < window.dayTo)
        #expect(window.dayKey == "2026-09-24")
    }
}

struct BabyHomeStatusMapperTests {
    @Test func mapsFixtureSummariesAndOpenSleep() throws {
        let json = """
        {
          "babyHomeQuickStatus": {
            "lastFeed": { "summary": "Bottle 120 ml · 25m" },
            "lastSleep": { "summary": "" },
            "lastDiaper": { "summary": "Wet · 1h" },
            "lastPump": null,
            "openSleep": { "occurredAt": "2026-09-24T10:00:00.000+07:00" },
            "birthDate": "2026-05-24",
            "recentBottleMl": [120, 90]
          }
        }
        """.data(using: .utf8)!
        let payload = try BabyHomeStatusMapper.decodeStatusData(json)
        let snap = BabyHomeStatusMapper.map(
            payload,
            now: ISO8601DateFormatter().date(from: "2026-09-24T12:00:00Z") ?? .now
        )
        #expect(snap.lastFeed.sentence == "Bottle 120 ml · 25m")
        #expect(snap.lastFeed.isEmpty == false)
        #expect(snap.lastNap.isEmpty == true)
        #expect(snap.openNapStartedAt != nil)
        #expect(snap.recentBottleMl == [120, 90])
    }

    @Test func missingFieldsAreSafe() throws {
        let json = #"{"babyHomeQuickStatus":{}}"#.data(using: .utf8)!
        let payload = try BabyHomeStatusMapper.decodeStatusData(json)
        let snap = BabyHomeStatusMapper.map(payload)
        #expect(snap.lastFeed.isEmpty)
        #expect(snap.openNapStartedAt == nil)
    }
}

@MainActor
final class StubGraphQLClient: BabyGraphQLClienting, @unchecked Sendable {
    var calls: [(document: String, variablesJSON: Data?)] = []
    var statusData: Data
    var error: Error?

    init(statusData: Data = Data(#"{"babyHomeQuickStatus":{}}"#.utf8)) {
        self.statusData = statusData
    }

    func execute(document: String, variablesJSON: Data?) async throws -> Data {
        calls.append((document, variablesJSON))
        if let error { throw error }
        if document.contains("babyHomeQuickStatus") {
            return statusData
        }
        return Data(#"{"babyQuickCare":{"replayed":false,"steps":[]}}"#.utf8)
    }
}

struct BabyLiveModelTests {
    @Test @MainActor func loadStatusUpdatesSnapshot() async throws {
        let status = """
        {"babyHomeQuickStatus":{"lastFeed":{"summary":"Live feed"},"birthDate":"2026-01-01"}}
        """.data(using: .utf8)!
        let stub = StubGraphQLClient(statusData: status)
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        await model.loadLiveStatus()
        #expect(model.snapshot.lastFeed.sentence == "Live feed")
        #expect(stub.calls.count == 1)
    }

    @Test @MainActor func breastStartDoesNotCallClient() async {
        let stub = StubGraphQLClient()
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        model.toggleTimed(.breastLeft)
        #expect(stub.calls.isEmpty)
        if case .running = model.breastLeft {
            // ok
        } else {
            Issue.record("Expected running")
        }
    }

    @Test @MainActor func breastStopSendsBreastRunning() async {
        let stub = StubGraphQLClient()
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        model.toggleTimed(.breastLeft)
        model.toggleTimed(.breastLeft)
        // Allow async Task to run
        try? await Task.sleep(for: .milliseconds(50))
        #expect(stub.calls.contains { $0.document.contains("babyQuickCare") })
        let careCall = stub.calls.first { $0.document.contains("babyQuickCare") }
        let body = careCall?.variablesJSON.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        #expect(body.contains("breastRunning"))
        #expect(body.contains("breast_l"))
    }

    @Test @MainActor func unauthorizedSetsReconnect() async {
        let stub = StubGraphQLClient()
        stub.error = BabyGraphQLError.graphQL(message: "nope", code: "UNAUTHORIZED")
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        await model.loadLiveStatus()
        #expect(model.needsReconnect)
        #expect(model.statusFail?.contains("Unauthorized") == true)
    }

    @Test @MainActor func unknownGraphQLErrorHidesRawServerMessage() async {
        let secret = "secret=mny_leaked_token_xyz"
        let stub = StubGraphQLClient()
        stub.error = BabyGraphQLError.graphQL(message: secret, code: "INTERNAL")
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        await model.loadLiveStatus()
        #expect(model.statusFail == BabyLiveStatusFailCopy.genericGraphQL)
        #expect(model.statusFail?.contains(secret) != true)
        #expect(!model.needsReconnect)
    }

    @Test func liveStatusFailCopyMapsKnownCases() {
        let auth = BabyLiveStatusFailCopy.from(
            BabyGraphQLError.graphQL(message: "x", code: "FORBIDDEN")
        )
        #expect(auth.text == BabyLiveStatusFailCopy.unauthorized)
        #expect(auth.needsReconnect)
        let generic = BabyLiveStatusFailCopy.from(
            BabyGraphQLError.graphQL(message: "db stack trace", code: nil)
        )
        #expect(generic.text == BabyLiveStatusFailCopy.genericGraphQL)
        #expect(!generic.needsReconnect)
    }

    @Test @MainActor func modelSelectDiaperWithDetailsIncludesAmount() async {
        let stub = StubGraphQLClient()
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        model.selectDiaper(
            .poop,
            details: DiaperSheetDraft(color: .yellow, texture: nil, amount: .medium)
        )
        try? await Task.sleep(for: .milliseconds(80))
        #expect(model.diaperDoneKind == .poop)
        #expect(model.selectedDiaperKind == nil)
        let careCall = stub.calls.first { $0.document.contains("babyQuickCare") }
        let body = careCall?.variablesJSON.flatMap { String(data: $0, encoding: .utf8) } ?? ""
        #expect(body.contains("dirty"))
        #expect(body.contains("yellow"))
        #expect(body.contains("medium"))
    }

    @Test @MainActor func modelSelectDiaperWetDoesNotKeepSelected() {
        let model = BabyHomeStatusModel()
        model.selectDiaper(.wet)
        #expect(model.diaperDoneKind == .wet)
        #expect(model.selectedDiaperKind == nil)
    }

    @Test @MainActor func retryLastFailureResendsSameClientRequestId() async {
        let stub = StubGraphQLClient()
        stub.error = BabyGraphQLError.transport
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        model.selectBottle(ml: 90)
        try? await Task.sleep(for: .milliseconds(80))
        let id = model.lastRetryClientRequestId
        #expect(id != nil)
        stub.error = nil
        await model.retryLastFailure()
        try? await Task.sleep(for: .milliseconds(80))
        let careCalls = stub.calls.filter { $0.document.contains("babyQuickCare") }
        #expect(careCalls.count >= 2)
        let bodies = careCalls.compactMap { $0.variablesJSON.flatMap { String(data: $0, encoding: .utf8) } }
        #expect(bodies.filter { $0.contains(id!) }.count >= 2)
        #expect(model.lastFailedControl == nil)
    }

    @Test @MainActor func statusFailRetryReloadsStatus() async {
        let stub = StubGraphQLClient()
        stub.error = BabyGraphQLError.transport
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        await model.loadLiveStatus()
        #expect(model.statusFail != nil)
        #expect(model.lastFailedControl == nil)
        stub.error = nil
        let before = stub.calls.count
        await model.retryLastFailure()
        #expect(stub.calls.count > before)
        #expect(model.statusFail == nil)
    }

    @Test @MainActor func isStatusLoadingTogglesAroundLoad() async {
        let stub = StubGraphQLClient()
        let model = BabyHomeStatusModel(mode: .live, graphQLClient: stub)
        #expect(!model.isStatusLoading)
        await model.loadLiveStatus()
        #expect(!model.isStatusLoading)
    }

    @Test @MainActor func deepLinkSettingsOpensSheet() {
        let model = BabyHomeStatusModel()
        model.applyDeepLink(BabyHomeDeepLink.settingsURL)
        #expect(model.showSettingsSheet)
        #expect(model.selectedPage == .feed)
    }

    @Test @MainActor func deepLinkSleepJumpsFromFeedWithoutKeepingFeed() {
        let model = BabyHomeStatusModel()
        #expect(model.selectedPage == .feed)
        model.applyDeepLink(BabyHomeDeepLink.url(page: .sleep))
        #expect(model.selectedPage == .sleep)
        #expect(!model.showSettingsSheet)
    }

    @Test @MainActor func deepLinkPumpJumpsFromSleep() {
        let model = BabyHomeStatusModel()
        model.selectedPage = .sleep
        model.applyDeepLink(BabyHomeDeepLink.url(page: .pump))
        #expect(model.selectedPage == .pump)
    }

    @Test @MainActor func logoutClearsTokenAndDisconnects() {
        let store = InMemoryBabyAPITokenStore()
        try? store.save("mny_test_token")
        let model = BabyHomeStatusModel(isConnected: true, mode: .live, graphQLClient: StubGraphQLClient())
        model.showSettingsSheet = true
        model.logout(tokenStore: store)
        #expect(store.load() == nil)
        #expect(!model.isConnected)
        #expect(model.graphQLClient == nil)
        #expect(model.lastFailedControl == nil)
        #expect(!model.showSettingsSheet)
        #expect(AuthGate.showsConnect(bypassAuth: false, isConnected: model.isConnected))
    }

    /// Leave clears token + disconnect; saved Cloud origin stays for reconnect.
    @Test @MainActor func logoutKeepsSavedBaseURL() {
        let previous = BabyAPIConfig.loadBaseURL()
        defer {
            if previous.isEmpty {
                BabyAPIConfig.clearBaseURL()
            } else {
                _ = BabyAPIConfig.saveBaseURL(previous)
            }
        }

        let saved = "http://127.0.0.1:3000"
        #expect(BabyAPIConfig.saveBaseURL(saved))

        let store = InMemoryBabyAPITokenStore()
        try? store.save("mny_test_token")
        let model = BabyHomeStatusModel(isConnected: true, mode: .live, graphQLClient: StubGraphQLClient())
        model.logout(tokenStore: store)

        #expect(store.load() == nil)
        #expect(!model.isConnected)
        #expect(model.graphQLClient == nil)
        #expect(BabyAPIConfig.loadBaseURL() == "http://127.0.0.1:3000")
        #expect(AuthGate.showsConnect(bypassAuth: false, isConnected: model.isConnected))
    }

    @Test func failChipCopyKeepsIdentity() {
        #expect(CareControlLabels.mlTitle(90) == "90 ml")
        #expect(CareControlLabels.failSubtitle(isFailed: true) == "Failed")
        #expect(
            CareControlLabels.timedTitle(side: .breastLeft, phase: .idle, isFailed: true) == "Left"
        )
        #expect(
            CareControlLabels.timedSubtitle(side: .breastLeft, phase: .idle, isFailed: true, elapsed: "")
                == "Failed"
        )
    }

    @Test func connectGuideCopyIsPresent() {
        #expect(ConnectGuideCopy.title == "Quick connect")
        #expect(ConnectGuideCopy.steps.count == 3)
    }

    @Test func retryHelperKeepsSameId() {
        let id = "abc123def456abc123def456abc123de"
        #expect(BabyClientRequestId.retrySame(id) == id)
    }

    @Test func carePageBackgroundDistinguishesFeedAndSleep() {
        let feed = CarePageBackground.kind(page: .feed, snapshot: .sampleNextFeed())
        let sleep = CarePageBackground.kind(page: .sleep, snapshot: .sampleOpenNap())
        #expect(CarePageBackground.tokenId(feed) == "feed")
        #expect(CarePageBackground.tokenId(sleep) == "sleep")
        #expect(feed != sleep)
    }

    @Test func carePageBackgroundMarksOverdueFeed() {
        var snap = BabyHomeStatusSnapshot.sampleNextFeed()
        snap.feedOverdueSeconds = 300
        snap.nextFeedInSeconds = nil
        let kind = CarePageBackground.kind(page: .feed, snapshot: snap)
        #expect(kind == .feedOverdue)
    }

    @Test func statusStoreRoundTripWithSuite() throws {
        let suite = "BabyCareStatusStoreTests.\(UUID().uuidString)"
        defer {
            BabyCareStatusStore.defaults(suiteName: suite)?
                .removePersistentDomain(forName: suite)
        }
        let snap = BabyHomeStatusSnapshot.sampleOpenNap()
        BabyCareStatusStore.save(snapshot: snap, suiteName: suite)
        let loaded = BabyCareStatusStore.load(suiteName: suite)
        #expect(loaded != nil)
        #expect(loaded?.openNapStartedAt != nil)
        #expect(loaded?.ageDays == snap.ageDays)
    }

    @Test func statusStoreEmptyFallsBackForWidgets() {
        let suite = "BabyCareStatusStoreEmpty.\(UUID().uuidString)"
        defer {
            BabyCareStatusStore.defaults(suiteName: suite)?
                .removePersistentDomain(forName: suite)
        }
        let snap = BabyCareStatusStore.snapshotForWidgets(suiteName: suite)
        #expect(snap.nextFeedInSeconds != nil || snap.openNapStartedAt == nil)
        let kind = BabyCarePrimarySignal.resolve(snap)
        guard case .nextFeed = kind else {
            // sampleNextFeed default
            if case .openNap = kind { return }
            Issue.record("Expected nextFeed from empty-store sample, got \(kind)")
            return
        }
    }

    @Test func statusStoreDTOExcludesTokenKeys() throws {
        let dto = BabyCareStatusStore.dto(from: .sampleNextFeed())
        let keys = try BabyCareStatusStore.encodedObjectKeys(dto)
        for forbidden in BabyCareStatusStore.forbiddenKeys {
            #expect(!keys.contains(forbidden))
            #expect(keys.allSatisfy { !$0.lowercased().contains(forbidden) })
        }
    }

    @Test func lastCareHeroCopyForOpenNapAndNextFeed() {
        let nap = BabyCarePrimarySignal.resolve(.sampleOpenNap())
        #expect(BabyCarePrimarySignal.heroKindLabel(nap) == "Nap")
        #expect(!BabyCarePrimarySignal.heroValue(nap).isEmpty)

        let feed = BabyCarePrimarySignal.resolve(.sampleNextFeed())
        #expect(BabyCarePrimarySignal.heroKindLabel(feed) == "Next feed")
        #expect(BabyCarePrimarySignal.heroValue(feed).hasSuffix("m"))
    }

    @Test func rectangularComplicationSecondaryLine() {
        let snap = BabyHomeStatusSnapshot.sampleOpenNap()
        let primary = BabyCarePrimarySignal.resolve(snap)
        let secondary = BabyCarePrimarySignal.secondaryLine(snapshot: snap, primary: primary)
        #expect(!secondary.isEmpty)
        #expect(secondary != BabyCarePrimarySignal.shortLabel(primary) || secondary.contains("feed") || secondary.contains("Feed") || secondary.contains("Nap") || !snap.lastFeed.isEmpty)
    }

    @Test func complicationDisplayPrefersOpenNap() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let display = BabyCareComplicationDisplay.resolve(.sampleOpenNap(now: now), now: now)
        guard case .running(let kind, _) = display.mode else {
            Issue.record("Expected running, got \(display.mode)")
            return
        }
        #expect(kind == .nap)
        #expect(display.color == .teal)
        #expect(display.deepLinkPage == .sleep)
        #expect(!display.kindLabel.isEmpty)
    }

    @Test func complicationDisplayPrefersBreastWhenNoNap() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleNextFeed(now: now)
        snap.openNapStartedAt = nil
        snap.runningTimerKind = .breastLeft
        snap.runningTimerStartedAt = now.addingTimeInterval(-90)
        let display = BabyCareComplicationDisplay.resolve(snap, now: now)
        guard case .running(let kind, let started) = display.mode else {
            Issue.record("Expected breast running, got \(display.mode)")
            return
        }
        #expect(kind == .breastLeft)
        #expect(started == snap.runningTimerStartedAt)
        #expect(display.deepLinkPage == .feed)
    }

    @Test func complicationDisplayPrefersPumpWhenNoNapOrBreast() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleNextFeed(now: now)
        snap.openNapStartedAt = nil
        snap.runningTimerKind = .pumpBoth
        snap.runningTimerStartedAt = now.addingTimeInterval(-30)
        let display = BabyCareComplicationDisplay.resolve(snap, now: now)
        guard case .running(let kind, _) = display.mode else {
            Issue.record("Expected pump running, got \(display.mode)")
            return
        }
        #expect(kind == .pumpBoth)
        #expect(display.deepLinkPage == .pump)
    }

    @Test func complicationDisplayNapBeatsBreast() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleOpenNap(now: now)
        snap.runningTimerKind = .breastRight
        snap.runningTimerStartedAt = now
        let display = BabyCareComplicationDisplay.resolve(snap, now: now)
        guard case .running(let kind, _) = display.mode else {
            Issue.record("Expected nap, got \(display.mode)")
            return
        }
        #expect(kind == .nap)
    }

    @Test func complicationDisplayIdleInRangeIsTeal() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let snap = BabyHomeStatusSnapshot.sampleNextFeed(now: now)
        let display = BabyCareComplicationDisplay.resolve(snap, now: now)
        guard case .idle(let kind, _, _) = display.mode else {
            Issue.record("Expected idle, got \(display.mode)")
            return
        }
        #expect(kind == .feed || kind == .diaper)
        #expect(display.color == .teal)
        #expect(!display.kindLabel.isEmpty)
        #expect(display.idleRelative != nil)
    }

    @Test func complicationDisplayIdleOutOfRangeIsRed() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let snap = BabyHomeStatusSnapshot.sampleOverdueFeed(now: now)
        let display = BabyCareComplicationDisplay.resolve(snap, now: now)
        guard case .idle(let kind, _, _) = display.mode else {
            Issue.record("Expected idle overdue, got \(display.mode)")
            return
        }
        #expect(kind == .feed)
        #expect(display.color == .red)
        #expect(!display.kindLabel.isEmpty)
    }

    @Test func complicationDisplayFixedPumpIgnoresNapTimer() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleOpenNap(now: now)
        snap.lastPumpAt = now.addingTimeInterval(-45 * 60)
        snap.lastPump = .init(
            iconSystemName: "drop.fill",
            sentence: "Pump 80 ml · 45m",
            isEmpty: false
        )
        let display = BabyCareComplicationDisplay.resolve(snap, careType: .pump, now: now)
        guard case .idle(let kind, _, _) = display.mode else {
            Issue.record("Expected idle pump, got \(display.mode)")
            return
        }
        #expect(kind == .pump)
        #expect(display.deepLinkPage == .pump)
    }

    @Test func complicationDisplayFixedSleepShowsNapTimer() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let snap = BabyHomeStatusSnapshot.sampleOpenNap(now: now)
        let display = BabyCareComplicationDisplay.resolve(snap, careType: .sleep, now: now)
        guard case .running(let kind, _) = display.mode else {
            Issue.record("Expected nap running, got \(display.mode)")
            return
        }
        #expect(kind == .nap)
        #expect(display.deepLinkPage == .sleep)
    }

    @Test func complicationDisplayFixedFeedShowsBreastNotNap() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleOpenNap(now: now)
        snap.runningTimerKind = .breastLeft
        snap.runningTimerStartedAt = now.addingTimeInterval(-60)
        let display = BabyCareComplicationDisplay.resolve(snap, careType: .feed, now: now)
        guard case .running(let kind, _) = display.mode else {
            Issue.record("Expected breast running, got \(display.mode)")
            return
        }
        #expect(kind == .breastLeft)
        #expect(display.deepLinkPage == .feed)
    }

    @Test func complicationDisplayFixedDiaperDeepLinksEvenWhenEmpty() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleNextFeed(now: now)
        snap.lastDiaperAt = nil
        snap.lastDiaper = .init(
            iconSystemName: "leaf.fill",
            sentence: "No diaper yet",
            isEmpty: true
        )
        let display = BabyCareComplicationDisplay.resolve(snap, careType: .diaper, now: now)
        #expect(display.mode == .empty)
        #expect(display.deepLinkPage == .diaper)
    }

    @Test func complicationCareTypeAutoDeepLinkFollowsResolved() {
        #expect(BabyCareComplicationCareType.auto.fixedDeepLinkPage == nil)
        #expect(BabyCareComplicationCareType.pump.fixedDeepLinkPage == .pump)
        #expect(BabyCareComplicationCareType.sleep.fixedDeepLinkPage == .sleep)
    }

    @Test func formatRelativeLinesUsesHoursOnlyWhenAtLeastOneHour() {
        let lines = BabyCareComplicationDisplay.formatRelativeLines(12 * 3600 + 38 * 60)
        #expect(lines.line1 == "12h")
        #expect(lines.line2 == nil)
        #expect(BabyCareComplicationDisplay.formatRelative(12 * 3600 + 38 * 60) == "12h")
    }

    @Test func formatRelativeLinesKeepsShortAgesOnOneLine() {
        #expect(BabyCareComplicationDisplay.formatRelativeLines(25 * 60) == ("25m", nil))
        #expect(BabyCareComplicationDisplay.formatRelativeLines(2 * 3600) == ("2h", nil))
        #expect(BabyCareComplicationDisplay.formatRelative(90 * 60) == "1h")
    }

    @Test func accessibilitySummaryRunningContainsKindWithoutOverdue() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let display = BabyCareComplicationDisplay.resolve(.sampleOpenNap(now: now), now: now)
        let summary = display.accessibilitySummary
        #expect(summary.contains("Nap"))
        #expect(!summary.localizedCaseInsensitiveContains("overdue"))
    }

    @Test func accessibilitySummaryIdleOverdueContainsKindAndOverdue() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let display = BabyCareComplicationDisplay.resolve(.sampleOverdueFeed(now: now), now: now)
        let summary = display.accessibilitySummary
        #expect(summary.localizedCaseInsensitiveContains("feed"))
        #expect(summary.localizedCaseInsensitiveContains("overdue"))
        #expect(display.showsOverdueCue)
    }

    @Test func accessibilitySummaryEmptyUsesClearCopy() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        var snap = BabyHomeStatusSnapshot.sampleNextFeed(now: now)
        snap.lastDiaperAt = nil
        snap.lastDiaper = .init(
            iconSystemName: "leaf.fill",
            sentence: "No diaper yet",
            isEmpty: true
        )
        let display = BabyCareComplicationDisplay.resolve(snap, careType: .diaper, now: now)
        #expect(display.mode == .empty)
        #expect(display.accessibilitySummary == BabyCareComplicationDisplay.emptyPrimaryText)
        #expect(BabyCareComplicationDisplay.emptyPrimaryText == "No care yet")
        #expect(!display.showsOverdueCue)
    }

    @Test func showsOverdueCueOnlyWhenIdleRed() {
        let now = Date(timeIntervalSince1970: 2_000_000)
        let overdue = BabyCareComplicationDisplay.resolve(.sampleOverdueFeed(now: now), now: now)
        #expect(overdue.showsOverdueCue)
        let inRange = BabyCareComplicationDisplay.resolve(.sampleNextFeed(now: now), now: now)
        #expect(!inRange.showsOverdueCue)
        let running = BabyCareComplicationDisplay.resolve(.sampleOpenNap(now: now), now: now)
        #expect(!running.showsOverdueCue)
    }

    @Test func careGuideFeedIntervalPositive() {
        #expect(CareGuideIntervals.feedMaxGapSeconds(ageDays: 10) > 0)
        #expect(CareGuideIntervals.diaperMaxGapSeconds(ageDays: 10) == 3 * 3600)
    }

    @Test func statusStorePersistsRunningBreast() throws {
        let suite = "BabyCareStatusStoreBreast.\(UUID().uuidString)"
        defer {
            BabyCareStatusStore.defaults(suiteName: suite)?
                .removePersistentDomain(forName: suite)
        }
        var snap = BabyHomeStatusSnapshot.sampleNextFeed()
        snap.openNapStartedAt = nil
        snap.runningTimerKind = .breastLeft
        snap.runningTimerStartedAt = Date(timeIntervalSince1970: 9_000)
        BabyCareStatusStore.save(snapshot: snap, suiteName: suite)
        let loaded = BabyCareStatusStore.snapshotForWidgets(suiteName: suite)
        #expect(loaded.runningTimerKind == .breastLeft)
        #expect(loaded.runningTimerStartedAt == snap.runningTimerStartedAt)
    }

    @Test func statusStorePersistsRunningPump() throws {
        let suite = "BabyCareStatusStorePump.\(UUID().uuidString)"
        defer {
            BabyCareStatusStore.defaults(suiteName: suite)?
                .removePersistentDomain(forName: suite)
        }
        var snap = BabyHomeStatusSnapshot.sampleNextFeed()
        snap.openNapStartedAt = nil
        snap.runningTimerKind = .pumpRight
        snap.runningTimerStartedAt = Date(timeIntervalSince1970: 9_100)
        BabyCareStatusStore.save(snapshot: snap, suiteName: suite)
        let loaded = BabyCareStatusStore.snapshotForWidgets(suiteName: suite)
        #expect(loaded.runningTimerKind == .pumpRight)
        #expect(loaded.runningTimerStartedAt == snap.runningTimerStartedAt)
    }

    @Test func mapperParsesLastFeedAtAndOverdue() throws {
        let now = Date(timeIntervalSince1970: 1_735_689_600)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let past = formatter.string(from: now.addingTimeInterval(-5 * 3600))
        let json = """
        {"babyHomeQuickStatus":{
          "lastFeed":{"at":"\(past)","summary":"Bottle 100 ml"},
          "birthDate":"2024-09-01"
        }}
        """
        let data = Data(json.utf8)
        let payload = try BabyHomeStatusMapper.decodeStatusData(data)
        let snap = BabyHomeStatusMapper.map(payload, now: now)
        #expect(snap.lastFeedAt != nil)
        #expect(snap.feedOverdueSeconds != nil)
    }
}

struct OfflineCareStoreTests {
    @Test func inMemoryAppendAndFetchRecent() async throws {
        let store = InMemoryOfflineCareStore()
        let older = CareEvent(kind: "bottle", at: Date(timeIntervalSince1970: 100), ml: 90)
        let newer = CareEvent(kind: "diaper", at: Date(timeIntervalSince1970: 200), diaperKind: "wet")
        try await store.append(older)
        try await store.append(newer)
        let recent = try await store.fetchRecent(limit: 10)
        #expect(recent.count == 2)
        #expect(recent.first?.kind == "diaper")
    }

    @Test func projectorSetsLastBottleAndDiaper() {
        let events = [
            CareEvent(kind: "bottle", at: Date(timeIntervalSince1970: 1), ml: 120),
            CareEvent(kind: "diaper", at: Date(timeIntervalSince1970: 2), diaperKind: "wet"),
        ]
        let snap = OfflineSnapshotProjector.make(events: events, ageDays: 100)
        #expect(snap.lastFeed.isEmpty == false)
        #expect(snap.lastFeed.sentence.contains("120"))
        #expect(snap.lastDiaper.isEmpty == false)
        #expect(snap.lastFeedAt != nil)
        #expect(snap.lastDiaperAt != nil)
    }

    @Test func projectorOpenNapFromNapStart() {
        let start = Date(timeIntervalSince1970: 50)
        let snap = OfflineSnapshotProjector.make(
            events: [CareEvent(kind: "nap_start", at: start)],
            ageDays: 90
        )
        #expect(snap.openNapStartedAt == start)
    }

    @Test func careDataModeStoreRoundTrip() {
        let suite = "CareDataModeStore.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        CareDataModeStore.save(.offline, defaults: defaults)
        #expect(CareDataModeStore.load(defaults: defaults) == .offline)
        CareDataModeStore.clear(defaults: defaults)
        #expect(CareDataModeStore.load(defaults: defaults) == nil)
    }

    @Test func shouldRestoreOfflineWhenSaved() {
        #expect(
            BabySessionRestore.shouldRestoreOffline(savedMode: .offline, isConnected: false)
        )
        #expect(
            !BabySessionRestore.shouldRestoreOffline(savedMode: .live, isConnected: false)
        )
        #expect(
            !BabySessionRestore.shouldRestoreOffline(savedMode: .offline, isConnected: true)
        )
    }

    @Test @MainActor func useOfflineConnectsWithoutToken() async throws {
        let store = InMemoryOfflineCareStore()
        let model = BabyHomeStatusModel()
        model.useOffline(store: store)
        #expect(model.mode == .offline)
        #expect(model.isConnected)
        #expect(model.graphQLClient == nil)
        try await store.append(CareEvent(kind: "bottle", ml: 100))
        await model.refreshOfflineSnapshot()
        #expect(model.snapshot.lastFeed.isEmpty == false)
        #expect(AuthGate.showsConnect(bypassAuth: false, isConnected: model.isConnected) == false)
    }

    @Test @MainActor func logoutClearsOfflineSessionButNotStoreEvents() async throws {
        let store = InMemoryOfflineCareStore()
        try await store.append(CareEvent(kind: "bottle", ml: 80))
        let model = BabyHomeStatusModel()
        model.useOffline(store: store)
        let tokenStore = InMemoryBabyAPITokenStore()
        model.logout(tokenStore: tokenStore)
        #expect(!model.isConnected)
        #expect(model.offlineStore == nil)
        let remaining = try await store.fetchRecent(limit: 10)
        #expect(remaining.count == 1)
    }

    @Test @MainActor func offlineBottleAppendsEvent() async throws {
        let store = InMemoryOfflineCareStore()
        let model = BabyHomeStatusModel()
        model.useOffline(store: store)
        model.selectBottle(ml: 150)
        try await Task.sleep(nanoseconds: 50_000_000)
        let events = try await store.fetchRecent(limit: 5)
        #expect(events.contains { $0.kind == "bottle" && $0.ml == 150 })
    }
}

struct PhoneSessionModelTests {
    @Test @MainActor func useOfflineConnectsWithHealthyStore() async {
        let store = InMemoryOfflineCareStore()
        let session = PhoneSessionModel()
        await session.useOffline(store: store)
        #expect(session.isConnected)
        #expect(session.mode == .offline)
        #expect(session.graphQLClient == nil)
        #expect(session.statusFail == nil)
        #expect(CloudKitOfflineCareStore.containerIdentifier == "iCloud.vn.in4.MyBaby")
    }

    @Test @MainActor func useOfflineFailsWhenStoreUnavailable() async {
        let store = FailingOfflineCareStore()
        let session = PhoneSessionModel()
        await session.useOffline(store: store)
        #expect(!session.isConnected)
        #expect(session.offlineStore == nil)
        #expect(session.statusFail != nil)
    }

    @Test @MainActor func leaveOfflineKeepsStoreEvents() async throws {
        let store = InMemoryOfflineCareStore()
        try await store.append(CareEvent(kind: "bottle", ml: 90))
        let session = PhoneSessionModel()
        await session.useOffline(store: store)
        let tokenStore = InMemoryBabyAPITokenStore()
        session.leave(tokenStore: tokenStore)
        #expect(!session.isConnected)
        #expect(session.offlineStore == nil)
        let remaining = try await store.fetchRecent(limit: 10)
        #expect(remaining.count == 1)
    }

    @Test @MainActor func pairSuccessEntersLive() async throws {
        let session = PhoneSessionModel()
        let tokenStore = InMemoryBabyAPITokenStore()
        let pair = FakeWatchPairClient(
            result: .success(WatchPairRedeemResult(baseURL: "http://127.0.0.1:3000", token: "mny_test"))
        )
        let ok = await session.connectWithPairingCode(
            code: "ABCD",
            pairClient: pair,
            tokenStore: tokenStore
        )
        #expect(ok)
        #expect(session.isConnected)
        #expect(session.mode == .live)
        #expect(tokenStore.load() == "mny_test")
    }

    @Test @MainActor func pairFailureShowsError() async {
        let session = PhoneSessionModel()
        let pair = FakeWatchPairClient(result: .failure(.pairCode("INVALID_CODE")))
        let ok = await session.connectWithPairingCode(
            code: "BAD",
            pairClient: pair,
            tokenStore: InMemoryBabyAPITokenStore()
        )
        #expect(!ok)
        #expect(!session.isConnected)
        #expect(session.statusFail != nil)
    }

    @Test @MainActor func leaveLiveClearsToken() async throws {
        let session = PhoneSessionModel()
        let tokenStore = InMemoryBabyAPITokenStore()
        try tokenStore.save("mny_live")
        #expect(
            session.connectWithPastedCredentials(
                baseURLRaw: "http://127.0.0.1:3000",
                token: "mny_live",
                tokenStore: tokenStore
            )
        )
        session.leave(tokenStore: tokenStore)
        #expect(!session.isConnected)
        #expect(tokenStore.load() == nil)
    }

    @Test @MainActor func coldStartRestoresOffline() async {
        let suite = "PhoneSessionRestore.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        CareDataModeStore.save(.offline, defaults: defaults)
        let session = PhoneSessionModel()
        let store = InMemoryOfflineCareStore()
        await session.restoreColdStart(
            tokenStore: InMemoryBabyAPITokenStore(),
            defaults: defaults,
            makeOfflineStore: { store }
        )
        #expect(session.isConnected)
        #expect(session.mode == .offline)
    }
}

struct PhoneCareWiringTests {
    @Test @MainActor func applyOfflineUsesSessionStoreWithoutGraphQL() async {
        let store = InMemoryOfflineCareStore()
        let session = PhoneSessionModel()
        await session.useOffline(store: store)
        let model = PhoneCareWiring.makeModel(from: session)
        #expect(model.mode == .offline)
        #expect(model.offlineStore != nil)
        #expect(model.graphQLClient == nil)
        #expect(model.isConnected)
    }

    @Test @MainActor func applyLiveUsesSessionClient() {
        let session = PhoneSessionModel()
        let stub = StubGraphQLClient()
        session.useLive(client: stub)
        let model = PhoneCareWiring.makeModel(from: session)
        #expect(model.mode == .live)
        #expect(model.graphQLClient != nil)
        #expect(model.offlineStore == nil)
        #expect(model.isConnected)
    }

    @Test @MainActor func refreshLiveCallsStatusDocument() async {
        let status = """
        {"babyHomeQuickStatus":{"lastFeed":{"summary":"Phone live"},"birthDate":"2026-01-01"}}
        """.data(using: .utf8)!
        let stub = StubGraphQLClient(statusData: status)
        let session = PhoneSessionModel()
        session.useLive(client: stub)
        let model = PhoneCareWiring.makeModel(from: session)
        await PhoneCareWiring.refreshStatus(model)
        #expect(stub.calls.contains { $0.document.contains("babyHomeQuickStatus") })
        #expect(model.snapshot.lastFeed.sentence == "Phone live")
        #expect(model.statusFail == nil)
    }

    @Test @MainActor func refreshOfflineDoesNotCallGraphQL() async {
        let store = InMemoryOfflineCareStore()
        let session = PhoneSessionModel()
        await session.useOffline(store: store)
        let stub = StubGraphQLClient()
        let model = PhoneCareWiring.makeModel(from: session)
        // Ensure offline path even if stub somehow attached
        model.graphQLClient = stub
        await PhoneCareWiring.refreshStatus(model)
        #expect(stub.calls.isEmpty)
    }
}

struct BabyCareWidgetKindsTests {
    @Test func reloadKindNamesIncludesWatchAndPhone() {
        #expect(BabyCareWidgetKinds.watchComplication == "BabyCareComplication")
        #expect(BabyCareWidgetKinds.phoneHome == "BabyCarePhoneHome")
        #expect(BabyCareWidgetKinds.reloadKindNames == [
            "BabyCareComplication",
            "BabyCarePhoneHome",
        ])
    }

    @Test func phoneHomeKindDistinctFromWatch() {
        #expect(BabyCareWidgetKinds.phoneHome != BabyCareWidgetKinds.watchComplication)
    }
}

// MARK: - phone-security-perf

final class RecordingOfflineCareStore: OfflineCareStoring, @unchecked Sendable {
    private let inner = InMemoryOfflineCareStore()
    private(set) var lastFetchLimit: Int?

    func append(_ event: CareEvent) async throws {
        try await inner.append(event)
    }

    func fetchRecent(limit: Int) async throws -> [CareEvent] {
        lastFetchLimit = limit
        return try await inner.fetchRecent(limit: limit)
    }
}

final class RecordingWidgetTimelineReloader: WidgetTimelineReloading, @unchecked Sendable {
    private(set) var reloadCount = 0

    func reloadCareWidgetKinds() {
        reloadCount += 1
    }
}

struct PhoneSecurityPerfTests {
    @Test func offlineFetchLimitIsEighty() {
        #expect(OfflineCareFetchLimits.recentForStatus == 80)
    }

    @Test func cloudKitDesiredKeysListCareEventFields() {
        let keys = Set(CloudKitOfflineCareStore.careEventDesiredKeys.map { String(describing: $0) })
        #expect(keys.isSuperset(of: [
            "kind", "at", "schemaVersion", "side", "ml", "diaperKind", "durationSec",
        ]))
    }

    @Test func careEventCloudKitRoundTrip() {
        let event = CareEvent(
            id: "e1",
            kind: "bottle",
            at: Date(timeIntervalSince1970: 1_700_000_000),
            ml: 90
        )
        let record = CloudKitOfflineCareStore.makeRecord(from: event)
        let back = CloudKitOfflineCareStore.event(from: record)
        #expect(back?.id == "e1")
        #expect(back?.kind == "bottle")
        #expect(back?.ml == 90)
    }

    @Test @MainActor func offlineRefreshRequestsStatusLimit() async {
        let store = RecordingOfflineCareStore()
        try? await store.append(CareEvent(kind: "bottle", ml: 60))
        let model = BabyHomeStatusModel()
        model.useOffline(store: store)
        await model.refreshOfflineSnapshot()
        #expect(store.lastFetchLimit == OfflineCareFetchLimits.recentForStatus)
    }

    @Test @MainActor func widgetReloadCoalescerFiresOnceAfterBurst() async {
        let reloader = RecordingWidgetTimelineReloader()
        let coalescer = WidgetTimelineReloadCoalescer(
            delay: .milliseconds(30),
            reloader: reloader
        )
        coalescer.schedule()
        coalescer.schedule()
        coalescer.schedule()
        #expect(coalescer.scheduleCount == 3)
        try? await Task.sleep(for: .milliseconds(80))
        #expect(coalescer.fireCount == 1)
        #expect(reloader.reloadCount == 1)
    }

    @Test @MainActor func persistStatusUsesCoalescerNotImmediateReload() async {
        let reloader = RecordingWidgetTimelineReloader()
        let model = BabyHomeStatusModel()
        model.widgetReloadCoalescer = WidgetTimelineReloadCoalescer(
            delay: .milliseconds(40),
            reloader: reloader
        )
        model.persistStatusForWidgets()
        model.persistStatusForWidgets()
        #expect(reloader.reloadCount == 0)
        try? await Task.sleep(for: .milliseconds(100))
        #expect(reloader.reloadCount == 1)
    }
}
