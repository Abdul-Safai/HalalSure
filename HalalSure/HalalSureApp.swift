import SwiftUI

@main
struct HalalSureApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .tint(Brand.green) // app-wide brand tint
        }
    }
}
