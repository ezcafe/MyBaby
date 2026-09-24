import SwiftUI

struct FeedPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showCustomBottle = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .feed,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Feed", detail: model.snapshot.feedHeaderDetail)
                HStack(spacing: 8) {
                    TimedCareChip(side: .breastLeft, phase: model.breastLeft, ticksEnabled: ticksEnabled) {
                        model.toggleTimed(.breastLeft)
                    }
                    TimedCareChip(side: .breastRight, phase: model.breastRight, ticksEnabled: ticksEnabled) {
                        model.toggleTimed(.breastRight)
                    }
                }
                CareMlAmountGrid(
                    mls: model.snapshot.bottleChipMls,
                    doneMl: model.bottleDoneMl,
                    onSelect: { model.selectBottle(ml: $0) },
                    onCustom: { showCustomBottle = true }
                )
                CareFooterSlot(content: model.footer(tip: model.snapshot.feedTip))
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showCustomBottle) {
            CustomMlPicker(title: "Bottle ml") { ml in
                model.selectBottle(ml: ml)
                showCustomBottle = false
            }
        }
    }
}

struct SleepPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .sleep,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Sleep", detail: nil)
            TimedCareChip(side: .nap, phase: model.nap, ticksEnabled: ticksEnabled) {
                model.toggleTimed(.nap)
            }
            CareFooterSlot(content: model.footer(tip: model.snapshot.sleepTip))
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct DiaperPage: View {
    @Bindable var model: BabyHomeStatusModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            CareSectionHeader(lead: "Diaper", detail: nil)
            DiaperKindGrid(
                done: model.diaperDoneKind,
                onSelect: { model.selectDiaper($0) }
            )
            CareFooterSlot(content: model.footer(tip: model.snapshot.diaperTip))
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct PumpPage: View {
    @Bindable var model: BabyHomeStatusModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showCustom = false

    private var ticksEnabled: Bool {
        CareTimerTicks.shouldTick(
            running: true,
            pageSelected: model.selectedPage == .pump,
            sceneActive: scenePhase == .active
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Pump", detail: model.snapshot.pumpTip)
                VStack(spacing: 6) {
                    HStack(spacing: 6) {
                        TimedCareChip(side: .pumpLeft, phase: model.pumpLeft, ticksEnabled: ticksEnabled) {
                            model.toggleTimed(.pumpLeft)
                        }
                        TimedCareChip(side: .pumpRight, phase: model.pumpRight, ticksEnabled: ticksEnabled) {
                            model.toggleTimed(.pumpRight)
                        }
                    }
                    TimedCareChip(side: .pumpBoth, phase: model.pumpBoth, ticksEnabled: ticksEnabled) {
                        model.toggleTimed(.pumpBoth)
                    }
                }
                CareMlAmountGrid(
                    mls: model.snapshot.bottleChipMls,
                    doneMl: model.pumpDoneMl,
                    onSelect: { model.selectPump(ml: $0) },
                    onCustom: { showCustom = true }
                )
                CareFooterSlot(content: model.footer(tip: model.snapshot.pumpTip))
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .sheet(isPresented: $showCustom) {
            CustomMlPicker(title: "Pump ml") { ml in
                model.selectPump(ml: ml)
                showCustom = false
            }
        }
    }
}

struct LastCarePage: View {
    @Environment(\.colorScheme) private var scheme
    @Bindable var model: BabyHomeStatusModel

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                CareSectionHeader(lead: model.snapshot.lastCareHeaderLead, detail: nil)
                statusRow(model.snapshot.lastFeed, palette: p)
                statusRow(model.snapshot.lastNap, palette: p)
                statusRow(model.snapshot.lastDiaper, palette: p)
                statusRow(model.snapshot.lastPump, palette: p)
            }
            .padding(.horizontal, 4)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func statusRow(_ line: BabyCareStatusLine, palette: BabyPalette) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(systemName: line.iconSystemName)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.accent)
                .frame(width: 22, alignment: .center)
                .accessibilityHidden(true)
            Text(line.sentence)
                .font(.caption)
                .foregroundStyle(line.isEmpty ? palette.muted : palette.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CustomMlPicker: View {
    static let visibleRowCount = 3
    static let rowHeight: CGFloat = 28
    static var wheelHeight: CGFloat { CGFloat(visibleRowCount) * rowHeight }

    let title: String
    let onPick: (Int) -> Void
    @State private var ml: Double = 120

    var body: some View {
        VStack(spacing: 12) {
            Text(title).font(.headline)
            Picker("ml", selection: $ml) {
                ForEach(Array(stride(from: 30, through: 240, by: 10)), id: \.self) { value in
                    Text("\(value) ml").tag(Double(value))
                }
            }
            .pickerStyle(.wheel)
            .frame(height: Self.wheelHeight)
            Button("Save") { onPick(Int(ml)) }
        }
        .padding()
    }
}
