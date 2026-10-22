import Foundation

struct ActionItem: Identifiable, Codable, Equatable {
    var id = UUID()
    var title = ""
    var details = ""
    var urlString = ""
    var isComplete = false
    var order = 0

    var url: URL? {
        let value = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty else { return nil }
        guard let candidate = URL(string: value), let scheme = candidate.scheme?.lowercased(),
              ["http", "https"].contains(scheme), candidate.host != nil else { return nil }
        return candidate
    }

    var domain: String? { url?.host() }
}

struct DailyPlan: Identifiable, Codable, Equatable {
    var id: String { dateKey }
    var dateKey: String
    var items: [ActionItem] = []
    var reminderTime: DateComponents?
    var reminderHandled = false
    var reminderScheduledFor: Date?
}

struct StoredData: Codable {
    var plans: [String: DailyPlan] = [:]
}

enum DateKeys {
    static let calendar: Calendar = { var c = Calendar.current; c.timeZone = .autoupdatingCurrent; return c }()
    static let formatter: DateFormatter = { let f = DateFormatter(); f.calendar = calendar; f.dateFormat = "yyyy-MM-dd"; return f }()
    static func key(_ date: Date) -> String { formatter.string(from: date) }
    static func date(from key: String) -> Date? { formatter.date(from: key) }
    static func tomorrow() -> Date { calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date() }
}
