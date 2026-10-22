import SwiftUI
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var notifications: NotificationService
    var body: some View { Form { Section("Notifications") { HStack { Text("Permission"); Spacer(); Text(status).foregroundStyle(.secondary) }; Button("Request Notification Permission") { Task { _ = await notifications.requestPermission() } }; Text("If permission is denied, enable DailyLaunch in System Settings → Notifications.").font(.caption).foregroundStyle(.secondary) }; Section("About") { Text("DailyLaunch"); Text("Version 1.0").foregroundStyle(.secondary) } }.formStyle(.grouped).padding(20).frame(width: 480, height: 300).task { await notifications.refreshAuthorizationStatus() } }
    private var status: String { switch notifications.authorizationStatus { case .authorized, .provisional: return "Allowed"; case .denied: return "Denied"; default: return "Not requested" } }
}
