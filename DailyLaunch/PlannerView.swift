import SwiftUI

struct PlannerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: DailyStore
    @EnvironmentObject private var notifications: NotificationService
    @State private var plan: DailyPlan
    @State private var adding = false; @State private var editing: ActionItem?; @State private var saved = false
    init() { _plan = State(initialValue: DailyPlan(dateKey: DateKeys.key(DateKeys.tomorrow()))) }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack { VStack(alignment: .leading) { Text("Plan Tomorrow").font(.title.bold()); Text(DateKeys.tomorrow(), style: .date).foregroundStyle(.secondary) }; Spacer(); Button("Cancel") { dismiss() }; Button("Save Plan") { save() }.buttonStyle(.borderedProminent) }
            Divider(); HStack { Text("Reminder time"); DatePicker("", selection: reminderBinding, displayedComponents: .hourAndMinute).labelsHidden(); Spacer(); if saved { Label("Saved", systemImage: "checkmark.circle.fill").foregroundStyle(.green) } }
            Text("Actions").font(.headline); List { ForEach(plan.items) { item in HStack { Image(systemName: "line.3.horizontal").foregroundStyle(.secondary); VStack(alignment: .leading) { Text(item.title); if let domain = item.domain { Text(domain).font(.caption).foregroundStyle(.secondary) } }; Spacer(); Button("Edit") { editing = item }; Button(role: .destructive) { plan.items.removeAll { $0.id == item.id } } label: { Image(systemName: "trash") }.buttonStyle(.borderless) }.padding(.vertical, 3) }.onMove { plan.items.move(fromOffsets: $0, toOffset: $1) } }.listStyle(.inset)
            HStack { Spacer(); Button("Add Action", systemImage: "plus") { adding = true } }
        }.padding(24).frame(minWidth: 600, minHeight: 450).onAppear { plan = store.tomorrow }.sheet(isPresented: $adding) { TaskEditor(date: DateKeys.tomorrow(), onSave: { plan.items.append($0) }) }.sheet(item: $editing) { item in TaskEditor(date: DateKeys.tomorrow(), item: item, onSave: { updated in if let i = plan.items.firstIndex(where: { $0.id == updated.id }) { plan.items[i] = updated } }) }
    }
    private var reminderBinding: Binding<Date> { Binding(get: { plan.reminderTime.flatMap { DateKeys.calendar.date(from: $0) } ?? Date() }, set: { plan.reminderTime = DateKeys.calendar.dateComponents([.hour, .minute], from: $0) }) }
    private func save() { plan.items.enumerated().forEach { plan.items[$0.offset].order = $0.offset }; store.save(plan); notifications.cancel(for: plan.dateKey); if plan.reminderTime != nil { notifications.schedule(for: plan, date: DateKeys.tomorrow()) }; saved = true }
}

struct TaskEditor: View {
    @Environment(\.dismiss) private var dismiss; @EnvironmentObject private var store: DailyStore
    let date: Date; var item: ActionItem?; var onSave: ((ActionItem) -> Void)?
    @State private var title = ""; @State private var details = ""; @State private var url = ""
    var body: some View { VStack(alignment: .leading, spacing: 14) { Text(item == nil ? "Add Action" : "Edit Action").font(.title2.bold()); TextField("Title (required)", text: $title); TextField("Description (optional)", text: $details); TextField("URL (optional)", text: $url); HStack { Spacer(); Button("Cancel") { dismiss() }; Button("Save") { save() }.buttonStyle(.borderedProminent).disabled(title.trimmingCharacters(in: .whitespaces).isEmpty) } }.padding(24).frame(width: 440).onAppear { title = item?.title ?? ""; details = item?.details ?? ""; url = item?.urlString ?? "" } }
    private func save() { var value = item ?? ActionItem(); value.title = title.trimmingCharacters(in: .whitespacesAndNewlines); value.details = details; value.urlString = url.trimmingCharacters(in: .whitespacesAndNewlines); if let onSave { onSave(value) } else { var p = store.plan(for: date); value.order = p.items.count; p.items.append(value); store.save(p) }; dismiss() }
}
