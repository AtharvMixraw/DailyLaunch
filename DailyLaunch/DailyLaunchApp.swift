import SwiftUI

@main
struct DailyLaunchApp: App {
    @StateObject private var store = DailyStore()
    @StateObject private var notifications = NotificationService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(notifications)
                .frame(minWidth: 760, minHeight: 520)
                .task { await notifications.refreshAuthorizationStatus() }
        }
        Settings {
            SettingsView()
                .environmentObject(store)
                .environmentObject(notifications)
        }
    }
}
