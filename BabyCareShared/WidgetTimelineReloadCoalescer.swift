import Foundation
import WidgetKit

/// Fires WidgetKit timeline reloads (testable).
protocol WidgetTimelineReloading: Sendable {
    func reloadCareWidgetKinds()
}

struct SystemWidgetTimelineReloader: WidgetTimelineReloading {
    func reloadCareWidgetKinds() {
        for kind in BabyCareWidgetKinds.reloadKindNames {
            WidgetCenter.shared.reloadTimelines(ofKind: kind)
        }
    }
}

/// Merges rapid reload requests into one wave after `delay`.
@MainActor
final class WidgetTimelineReloadCoalescer {
    private let delay: Duration
    private let reloader: any WidgetTimelineReloading
    private var pending: Task<Void, Never>?

    private(set) var scheduleCount = 0
    private(set) var fireCount = 0

    init(
        delay: Duration = .milliseconds(750),
        reloader: any WidgetTimelineReloading = SystemWidgetTimelineReloader()
    ) {
        self.delay = delay
        self.reloader = reloader
    }

    func schedule() {
        scheduleCount += 1
        pending?.cancel()
        pending = Task { @MainActor in
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            fireCount += 1
            reloader.reloadCareWidgetKinds()
        }
    }
}
