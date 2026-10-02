import SwiftUI

/// App entry point. Creates the single DataStore and hands it to every screen
/// through the environment.
@main struct MyApp: App {
    @State private var store = DataStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
