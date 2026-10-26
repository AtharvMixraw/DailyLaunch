import SwiftUI

@main
struct DailyLaunchApp: App {
    @StateObject private var store = DailyStore()
    @StateObject private var notifications = NotificationService()
    @StateObject private var capture = CaptureService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(notifications)
                .environmentObject(capture)
                .frame(minWidth: 760, minHeight: 520)
                .task { await notifications.refreshAuthorizationStatus(); capture.start() }
        }
        Settings {
            SettingsView()
                .environmentObject(store)
                .environmentObject(notifications)
        }
    }
}
