import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: DailyStore
    @EnvironmentObject private var notifications: NotificationService
    @State private var showingPlanner = false
    @State private var showingSettings = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationSplitView {
            List {
                Label("Today's Actions", systemImage: "checklist")
                    .tag(0)
                Button { showingPlanner = true } label: { Label("Plan Tomorrow", systemImage: "calendar.badge.plus") }
                Button { showingSettings = true } label: { Label("Settings", systemImage: "gear") }
            }.listStyle(.sidebar).navigationTitle("DailyLaunch")
        } detail: {
            DashboardView(showingPlanner: $showingPlanner, errorMessage: $errorMessage)
        }
        .sheet(isPresented: $showingPlanner) { PlannerView() }
        .sheet(isPresented: $showingSettings) { SettingsView() }
        .alert("Unable to open URL", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) { Button("OK") {} } message: { Text(errorMessage ?? "This URL is invalid.") }
    }
}

struct DashboardView: View {
    @EnvironmentObject private var store: DailyStore
    @EnvironmentObject private var notifications: NotificationService
    @Binding var showingPlanner: Bool; @Binding var errorMessage: String?
    @State private var editing: ActionItem?
    @State private var adding = false
    var plan: DailyPlan { store.today }
    var completed: Int { plan.items.filter(\.isComplete).count }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack { VStack(alignment: .leading) { Text("Today's Actions").font(.largeTitle.bold()); Text(Date(), style: .date).foregroundStyle(.secondary) }; Spacer(); Button("Open All", systemImage: "arrow.up.right.square") { openAll() }.disabled(plan.items.allSatisfy { $0.url == nil }); Button("Add Task", systemImage: "plus") { adding = true }.buttonStyle(.borderedProminent) }
            ProgressView(value: plan.items.isEmpty ? 0 : Double(completed), total: Double(max(plan.items.count, 1)))
            Text("\(completed) of \(plan.items.count) complete").font(.subheadline).foregroundStyle(.secondary)
            if plan.items.isEmpty { EmptyStateView() }
            else { List { ForEach(plan.items) { item in ActionRow(item: item, onToggle: { toggle(item) }, onStart: { if !notifications.open(item) { errorMessage = "Check that the task contains a valid http or https URL." } }, onEdit: { editing = item }, onDelete: { store.delete(item, from: Date()) }) }.onMove { from, to in var p = plan; p.items.move(fromOffsets: from, toOffset: to); p.items.enumerated().forEach { p.items[$0.offset].order = $0.offset }; store.save(p) } }.listStyle(.inset) }
        }.padding(28).sheet(isPresented: $adding) { TaskEditor(date: Date()) }.sheet(item: $editing) { item in TaskEditor(date: Date(), item: item) }
    }
    private func toggle(_ item: ActionItem) { var p = plan; if let i = p.items.firstIndex(where: { $0.id == item.id }) { p.items[i].isComplete.toggle(); store.save(p) } }
    private func openAll() { plan.items.filter { $0.url != nil }.forEach { _ = notifications.open($0) } }
}

private struct EmptyStateView: View {
    var body: some View { VStack(spacing: 10) { Image(systemName: "checklist").font(.system(size: 34)).foregroundStyle(.secondary); Text("No actions yet").font(.headline); Text("Add an action or plan tomorrow's work.").foregroundStyle(.secondary) }.frame(maxWidth: .infinity, maxHeight: .infinity) }
}

struct ActionRow: View { let item: ActionItem; let onToggle: () -> Void; let onStart: () -> Void; let onEdit: () -> Void; let onDelete: () -> Void
    var body: some View { HStack { Button(action: onToggle) { Image(systemName: item.isComplete ? "checkmark.circle.fill" : "circle").foregroundStyle(item.isComplete ? .green : .secondary) }.buttonStyle(.plain); VStack(alignment: .leading) { Text(item.title).strikethrough(item.isComplete); if !item.details.isEmpty { Text(item.details).font(.caption).foregroundStyle(.secondary) }; if let domain = item.domain { Text(domain).font(.caption).foregroundStyle(.blue) } }; Spacer(); Button("Start", action: onStart).disabled(item.url == nil); Menu { Button("Edit", action: onEdit); Button("Delete", role: .destructive, action: onDelete) } label: { Image(systemName: "ellipsis.circle") }.menuStyle(.borderlessButton) }.padding(.vertical, 4) }
}
