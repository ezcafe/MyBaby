import Foundation

/// WidgetKit timeline kind strings for App Group status reloads.
enum BabyCareWidgetKinds {
    static let watchComplication = "BabyCareComplication"
    static let phoneHome = "BabyCarePhoneHome"

    /// Kinds reloaded after `persistStatusForWidgets`.
    static let reloadKindNames: [String] = [watchComplication, phoneHome]
}
