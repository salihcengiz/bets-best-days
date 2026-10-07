import SwiftUI

/// App entry point. Creates the single DataStore and hands it to every screen
/// through the environment.
@main struct MyApp: App {
    @State private var store = DataStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}

/// Decides which top-level screen to show:
/// lock screen until the unlock moment, then the welcome screen once, then the app.
/// Also asks for notification permission and reschedules notifications whenever
/// the app comes to the foreground.
private struct RootView: View {
    @Environment(DataStore.self) private var store
    @Environment(\.scenePhase) private var scenePhase

    private enum Stage {
        case locked, welcome, app
    }

    var body: some View {
        // Re-evaluates exactly at the unlock moment, so the lock lifts while the app is open.
        TimelineView(.explicit([store.appUnlockDate])) { _ in
            let stage = currentStage(now: .now)
            Group {
                switch stage {
                case .locked: LockView()
                case .welcome: WelcomeView()
                case .app: ContentView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.3), value: stage)
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }
            // The system prompt appears only the first time (at install, over the lock screen).
            await NotificationManager.requestPermission()
            await NotificationManager.reschedule(store: store)
        }
    }

    private func currentStage(now: Date) -> Stage {
        if store.isAppLocked(now: now) { return .locked }
        if !store.hasSeenWelcome { return .welcome }
        return .app
    }
}
