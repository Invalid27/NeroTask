// Views/macOS/SidebarView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct SidebarView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    @Query(filter: #Predicate<Task> { !$0.isCompleted })
    private var incompleteTasks: [Task]
    
    @Query(filter: #Predicate<Task> { $0.isToday && !$0.isCompleted })
    private var todayTasks: [Task]
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate != nil
    })
    private var upcomingTasks: [Task]
    
    @Query(filter: #Predicate<Task> { $0.isCompleted })
    private var completedTasks: [Task]
    
    var body: some View {
        List(selection: $appState.selectedView) {
            Section {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label {
                            HStack {
                                Text(item.rawValue)
                                    .font(.system(size: 13, weight: .medium))
                                Spacer()
                                if let count = taskCount(for: item), count > 0 {
                                    Text("\(count)")
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(badgeColor(for: item))
                                        .cornerRadius(8)
                                }
                            }
                        } icon: {
                            Image(systemName: item.icon)
                                .font(.system(size: 14))
                                .foregroundColor(iconColor(for: item))
                        }
                    }
                }
            } header: {
                Text("TASKS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Section {
                ForEach(filterOptions) { filter in
                    NavigationLink(value: filter) {
                        Label {
                            HStack {
                                Text(filter.name)
                                    .font(.system(size: 13, weight: .medium))
                                Spacer()
                                if filter.count > 0 {
                                    Text("\(filter.count)")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: filter.icon)
                                .font(.system(size: 14))
                                .foregroundColor(filter.color)
                        }
                    }
                }
            } header: {
                Text("FILTERS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button(action: { appState.showingQuickEntry = true }) {
                    Label("Add Task", systemImage: "plus.circle.fill")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Tasks")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 12))
                }
            }
        }
    }
    
    private func taskCount(for item: SidebarItem) -> Int? {
        switch item {
        case .inbox: return incompleteTasks.count
        case .today: return todayTasks.count
        case .upcoming: return upcomingTasks.count
        case .anytime: return incompleteTasks.filter { $0.dueDate == nil && !$0.isToday }.count
        case .completed: return completedTasks.count
        }
    }
    
    private func badgeColor(for item: SidebarItem) -> Color {
        switch item {
        case .today: return .orange
        case .upcoming: return .blue
        default: return .gray.opacity(0.5)
        }
    }
    
    private func iconColor(for item: SidebarItem) -> Color {
        switch item {
        case .inbox: return .blue
        case .today: return .orange
        case .upcoming: return .purple
        case .anytime: return .green
        case .completed: return .gray
        }
    }
    
    private var filterOptions: [FilterOption] {
        [
            FilterOption(name: "High Priority", icon: "exclamationmark.circle.fill", color: .red, count: highPriorityCount),
            FilterOption(name: "Has Notes", icon: "note.text", color: .yellow, count: notesCount),
            FilterOption(name: "Overdue", icon: "clock.badge.exclamationmark", color: .red, count: overdueCount)
        ]
    }
    
    private var highPriorityCount: Int {
        incompleteTasks.filter { $0.priority == .high || $0.priority == .urgent }.count
    }
    
    private var notesCount: Int {
        incompleteTasks.filter { !$0.notes.isEmpty }.count
    }
    
    private var overdueCount: Int {
        incompleteTasks.filter { $0.isOverdue }.count
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

// MARK: - Filter Option
struct FilterOption: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let count: Int
}

// MARK: - Sidebar Item
enum SidebarItem: String, CaseIterable, Identifiable, Hashable {
    case inbox = "Inbox"
    case today = "Today"
    case upcoming = "Upcoming"
    case anytime = "Anytime"
    case completed = "Completed"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .inbox: return "tray.fill"
        case .today: return "star.fill"
        case .upcoming: return "calendar"
        case .anytime: return "archivebox.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }
}
#endif
