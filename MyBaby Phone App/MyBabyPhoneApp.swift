import SwiftUI

@main
struct MyBabyPhoneApp: App {
    var body: some Scene {
        WindowGroup {
            PhoneContentView(bypassAuth: false)
        }
    }
}
