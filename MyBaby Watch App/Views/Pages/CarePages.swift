import SwiftUI

struct FeedBottlePage: View {
    @Environment(\.colorScheme) private var scheme
    @Bindable var model: BabyHomeStatusModel
    @State private var showCustomBottle = false

    var body: some View {
        let p = BabyPalette(scheme: scheme)
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Feed", detail: model.snapshot.feedHeaderDetail)
                HStack(spacing: 8) {
                    TimedCareChip(side: .breastLeft, phase: model.breastLeft, now: model.now) {
                        model.toggleTimed(.breastLeft)
                    }
                    TimedCareChip(side: .breastRight, phase: model.breastRight, now: model.now) {
                        model.toggleTimed(.breastRight)
                    }
                }

                Divider().overlay(p.hairline)

                CareSectionHeader(lead: "Bottle", detail: model.snapshot.bottleTip)
                MlChipRow(
                    mls: model.snapshot.bottleChipMls,
                    selected: model.selectedBottleMl,
                    doneMl: model.bottleDoneMl,
                    onSelect: { model.selectBottle(ml: $0) },
                    onCustom: { showCustomBottle = true }
                )

                CareFooterSlot(content: model.footer(tip: model.snapshot.feedTip))
            }
            .padding(.horizontal, 4)
        }
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

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Sleep", detail: nil)
                TimedCareChip(side: .nap, phase: model.nap, now: model.now) {
                    model.toggleTimed(.nap)
                }
                CareFooterSlot(content: model.footer(tip: model.snapshot.sleepTip))
            }
            .padding(.horizontal, 4)
        }
    }
}

struct DiaperPage: View {
    @Bindable var model: BabyHomeStatusModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Diaper", detail: nil)
                DiaperKindGrid(
                    selected: model.selectedDiaperKind,
                    done: model.diaperDoneKind,
                    onSelect: { model.selectDiaper($0) }
                )
                CareFooterSlot(content: model.footer(tip: model.snapshot.diaperTip))
            }
            .padding(.horizontal, 4)
        }
    }
}

struct PumpPage: View {
    @Bindable var model: BabyHomeStatusModel
    @State private var showCustom = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                CareSectionHeader(lead: "Pump", detail: nil)
                HStack(spacing: 8) {
                    TimedCareChip(side: .pumpLeft, phase: model.pumpLeft, now: model.now) {
                        model.toggleTimed(.pumpLeft)
                    }
                    TimedCareChip(side: .pumpRight, phase: model.pumpRight, now: model.now) {
                        model.toggleTimed(.pumpRight)
                    }
                }
                MlChipRow(
                    mls: model.snapshot.bottleChipMls,
                    selected: model.selectedPumpMl,
                    doneMl: model.pumpDoneMl,
                    onSelect: { model.selectPump(ml: $0) },
                    onCustom: { showCustom = true }
                )
                CareFooterSlot(content: model.footer(tip: model.snapshot.pumpTip))
            }
            .padding(.horizontal, 4)
        }
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
                CareSectionHeader(lead: "Last care", detail: nil)
                statusRow(model.snapshot.lastFeed, palette: p)
                statusRow(model.snapshot.lastNap, palette: p)
                statusRow(model.snapshot.lastDiaper, palette: p)
                statusRow(model.snapshot.lastPump, palette: p)
            }
            .padding(.horizontal, 4)
        }
    }

    private func statusRow(_ line: BabyCareStatusLine, palette: BabyPalette) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: line.iconSystemName)
                .foregroundStyle(palette.accent)
            Text(line.sentence)
                .font(.caption)
                .foregroundStyle(line.isEmpty ? palette.muted : palette.foreground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CustomMlPicker: View {
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
            Button("Save") { onPick(Int(ml)) }
        }
        .padding()
    }
}
