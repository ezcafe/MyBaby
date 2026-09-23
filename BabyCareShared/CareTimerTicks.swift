import Foundation

/// When a running care chip should drive a 1 Hz `TimelineView`.
enum CareTimerTicks {
    static func shouldTick(running: Bool, pageSelected: Bool, sceneActive: Bool) -> Bool {
        running && pageSelected && sceneActive
    }
}
