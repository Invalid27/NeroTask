// Views/UpcomingView.swift
import SwiftUI
import SwiftData

struct UpcomingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate != nil
    }, sort: \Task.dueDate) private var tasks: [Task]
    
    var filteredTasks: [Task] {
        if appState.searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
    }
    
    var groupedTasks: [(String, [Task])] {
        Dictionary(grouping: filteredTasks) { task in
            groupKey(for: task.dueDate!)
        }
        .sorted { $0.value.first?.dueDate ?? Date() < $1.value.first?.dueDate ?? Date() }
        .map { ($0.key, $0.value) }
    }
    
    var body: some View {
        ScrollView {
            if filteredTasks.isEmpty {
                emptyStateView
            } else {
                LazyVStack(alignment: .leading, spacing: 24, pinnedViews: .sectionHeaders) {
                    ForEach(groupedTasks, id: \.0) { group in
                        Section {
                            VStack(spacing: 8) {
                                ForEach(group.1) { task in
                                    TaskRowView(task: task)
                                        .transition(.asymmetric(
                                            insertion: .push(from: .trailing).combined(with: .opacity),
                                            removal: .scale.combined(with: .opacity)
                                        ))
                                }
                            }
                        } header: {
                            sectionHeader(title: group.0, count: group.1.count)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle("Upcoming")
        #if os(macOS)
        .navigationSubtitle("\(tasks.count) scheduled task\(tasks.count == 1 ? "" : "s")")
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("Sort by Date") {
                        // Implement sort
                    }
                    Button("Sort by Priority") {
                        // Implement sort
                    }
                    Button("Sort by Title") {
                        // Implement sort
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        #endif
    }
    
    // MARK: - Section Header
    private func sectionHeader(title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("\(count)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(headerColor(for: title))
                .cornerRadius(8)
            
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.95))
    }
    
    private func headerColor(for title: String) -> Color {
        switch title {
        case "Overdue":
            return .red
        case "Today":
            return .orange
        case "Tomorrow":
            return .blue
        case "This Week":
            return .purple
        case "Next Week":
            return .indigo
        default:
            return .gray
        }
    }
    
    private func groupKey(for date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if date < now && !calendar.isDateInToday(date) {
            return "Overdue"
        } else if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            return "This Week"
        } else if let nextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: now),
                  calendar.isDate(date, equalTo: nextWeek, toGranularity: .weekOfYear) {
            return "Next Week"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .month) {
            return "This Month"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple.opacity(0.5), .indigo.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Upcoming Tasks")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Tasks with due dates will appear here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Button(action: { appState.showingQuickEntry = true }) {
                Label("Create Task with Due Date", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(BorderedProminentButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
