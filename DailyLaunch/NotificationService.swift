import Foundation
import UserNotifications
import AppKit

@MainActor final class NotificationService: NSObject, ObservableObject {
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    func refreshAuthorizationStatus() async {
        authorizationStatus = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    func requestPermission() async -> Bool {
        let granted = (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])) ?? false
        await refreshAuthorizationStatus(); return granted
    }

    func schedule(for plan: DailyPlan, date: Date) {
        guard let time = plan.reminderTime, let hour = time.hour, let minute = time.minute else { return }
        let content = UNMutableNotificationContent(); content.title = "DailyLaunch"; content.body = "Your plan for today is ready."; content.sound = .default
        var components = DateKeys.calendar.dateComponents([.year, .month, .day], from: date); components.hour = hour; components.minute = minute
        let request = UNNotificationRequest(identifier: identifier(for: plan.dateKey), content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false))
        UNUserNotificationCenter.current().add(request)
    }

    func cancel(for dateKey: String) { UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier(for: dateKey)]) }
    private func identifier(for key: String) -> String { "dailylaunch.reminder.\(key)" }

    func open(_ item: ActionItem) -> Bool {
        guard let url = item.url else { return false }; return NSWorkspace.shared.open(url)
    }
}
