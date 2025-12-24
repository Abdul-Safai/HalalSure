import SwiftUI

@main
struct HalalSureApp: App {
    var body: some Scene {
        WindowGroup {
            RootTab()
                .tint(Brand.green)
        }
    }
}

struct RootTab: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }

            // placeholders so the tab bar is obvious
            LearnPlaceholderView(title: "Learn")
                .tabItem { Label("Learn", systemImage: "book.closed.fill") }

            ReportPlaceholderView()
                .tabItem { Label("Report", systemImage: "exclamationmark.bubble.fill") }
        }
    }
}
