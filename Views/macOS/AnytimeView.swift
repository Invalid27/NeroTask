// Views/macOS/AnytimeView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct AnytimeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate == nil && !task.isToday
    }, sort: [
        SortDescriptor(\.priority, order: .reverse),
        SortDescriptor(\.createdDate, order: .reverse)
    ]) private var tasks: [Task]
    
    var filteredTasks: [Task] {
        if appState.searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
    }
    
    var groupedByPriority: [(TaskPriority, [Task])] {
        let grouped = Dictionary(grouping: filteredTasks) { $0.priority }
        return TaskPriority.allCases.reversed().compactMap { priority in
            guard let tasks = grouped[priority], !tasks.isEmpty else { return nil }
            return (priority, tasks)
        }
    }
    
    var body: some View {
        ScrollView {
            if filteredTasks.isEmpty {
                emptyStateView
            } else {
                LazyVStack(alignment: .leading, spacing: 24) {
                    // Statistics Card
                    statisticsCard
                    
                    // Tasks grouped by priority
                    ForEach(groupedByPriority, id: \.0) { priority, tasks in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: priority.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(priority.color)
                                
                                Text("\(priority.label) Priority")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("\(tasks.count)")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(priority.color)
                                    .cornerRadius(8)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 8) {
                                ForEach(tasks) { task in
                                    TaskRowView(task: task)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Anytime")
        #if os(macOS)
        .navigationSubtitle("\(tasks.count) task\(tasks.count == 1 ? "" : "s") in backlog")
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("Move All to Today") {
                        moveAllToToday()
                    }
                    .disabled(filteredTasks.isEmpty)
                    
                    Button("Set Due Dates...") {
                        // Implement batch due date setting
                    }
                    .disabled(filteredTasks.isEmpty)
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
        #endif
    }
    
    // MARK: - Statistics Card
    private var statisticsCard: some View {
        HStack(spacing: 30) {
            StatItem(
                title: "Total",
                value: "\(tasks.count)",
                icon: "archivebox.fill",
                color: .green
            )
            
            StatItem(
                title: "High Priority",
                value: "\(tasks.filter { $0.priority == .high || $0.priority == .urgent }.count)",
                icon: "exclamationmark.circle.fill",
                color: .orange
            )
            
            StatItem(
                title: "With Notes",
                value: "\(tasks.filter { !$0.notes.isEmpty }.count)",
                icon: "note.text",
                color: .blue
            )
            
            StatItem(
                title: "Oldest",
                value: oldestTaskAge,
                icon: "clock.fill",
                color: .purple
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
        )
    }
    
    private var oldestTaskAge: String {
        guard let oldestTask = tasks.last else { return "—" }
        let days = Calendar.current.dateComponents([.day], from: oldestTask.createdDate, to: Date()).day ?? 0
        
        if days == 0 {
            return "Today"
        } else if days == 1 {
            return "1 day"
        } else if days < 7 {
            return "\(days) days"
        } else if days < 30 {
            let weeks = days / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        } else {
            let months = days / 30
            return "\(months) month\(months == 1 ? "" : "s")"
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green.opacity(0.5), .mint.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Anytime Tasks")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Tasks without dates or today flag appear here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Text("💡 Tip: Use this for tasks you'll get to eventually")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
                .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Actions
    private func moveAllToToday() {
        withAnimation {
            for task in filteredTasks {
                task.isToday = true
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Stat Item
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
#endif
