import Foundation
import Combine

@MainActor final class DailyStore: ObservableObject {
    @Published private(set) var data: StoredData
    private let fileURL: URL

    init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("DailyLaunch", isDirectory: true)
        try? FileManager.default.createDirectory(at: appSupport, withIntermediateDirectories: true)
        fileURL = appSupport.appendingPathComponent("plans.json")
        if let bytes = try? Data(contentsOf: fileURL), let decoded = try? JSONDecoder().decode(StoredData.self, from: bytes) {
            data = decoded
        } else { data = StoredData() }
    }

    var today: DailyPlan { plan(for: Date()) }
    var tomorrow: DailyPlan { plan(for: DateKeys.tomorrow()) }

    func plan(for date: Date) -> DailyPlan { data.plans[DateKeys.key(date)] ?? DailyPlan(dateKey: DateKeys.key(date)) }

    func save(_ plan: DailyPlan) {
        data.plans[plan.dateKey] = plan
        persist()
    }

    func delete(_ item: ActionItem, from date: Date) {
        var plan = plan(for: date); plan.items.removeAll { $0.id == item.id }; save(plan)
    }

    private func persist() {
        guard let bytes = try? JSONEncoder().encode(data) else { return }
        try? bytes.write(to: fileURL, options: .atomic)
    }
}
