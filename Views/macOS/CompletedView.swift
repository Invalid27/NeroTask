// Views/macOS/CompletedView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct CompletedView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { $0.isCompleted },
           sort: [SortDescriptor(\.completedDate, order: .reverse)])
    private var tasks: [Task]
    
    @State private var selectedPeriod: TimePeriod = .all
    
    var filteredTasks: [Task] {
        let searchFiltered = appState.searchText.isEmpty ? tasks : tasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
        
        return searchFiltered.filter { task in
            guard let completedDate = task.completedDate else { return false }
            
            switch selectedPeriod {
            case .all:
                return true
            case .today:
                return Calendar.current.isDateInToday(completedDate)
            case .yesterday:
                return Calendar.current.isDateInYesterday(completedDate)
            case .thisWeek:
                return Calendar.current.isDate(completedDate, equalTo: Date(), toGranularity: .weekOfYear)
            case .lastWeek:
                guard let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return false }
                return Calendar.current.isDate(completedDate, equalTo: lastWeek, toGranularity: .weekOfYear)
            case .thisMonth:
                return Calendar.current.isDate(completedDate, equalTo: Date(), toGranularity: .month)
            }
        }
    }
    
    var statistics: TaskStatistics {
        TaskStatistics(tasks: filteredTasks)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with filters
            headerView
            
            if tasks.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    VStack(spacing: 20) {
                        // Statistics
                        statisticsView
                        
                        // Completed tasks list
                        completedTasksList
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Completed")
        .navigationSubtitle("\(filteredTasks.count) completed task\(filteredTasks.count == 1 ? "" : "s")")
        .toolbar {
            ToolbarItemGroup {
                Button(action: clearAllCompleted) {
                    Image(systemName: "trash")
                        .help("Clear all completed tasks")
                }
                .disabled(filteredTasks.isEmpty)
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(TimePeriod.allCases) { period in
                        PeriodChip(
                            period: period,
                            isSelected: selectedPeriod == period,
                            count: countTasks(for: period)
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedPeriod = period
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            Divider()
        }
        .padding(.vertical, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        HStack(spacing: 20) {
            StatCard(
                title: "Completed",
                value: "\(statistics.totalCompleted)",
                icon: "checkmark.circle.fill",
                color: .green
            )
            
            StatCard(
                title: "Streak",
                value: "\(statistics.currentStreak) days",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Avg. Time",
                value: statistics.averageCompletionTime,
                icon: "clock.fill",
                color: .blue
            )
            
            StatCard(
                title: "Best Day",
                value: statistics.bestDay,
                icon: "star.fill",
                color: .purple
            )
        }
    }
    
    // MARK: - Completed Tasks List
    private var completedTasksList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed Tasks")
                .font(.system(size: 16, weight: .semibold))
            
            VStack(spacing: 8) {
                ForEach(filteredTasks) { task in
                    CompletedTaskRow(task: task) {
                        uncompleteTask(task)
                    } onDelete: {
                        deleteTask(task)
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.seal")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green.opacity(0.6), .mint.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Completed Tasks Yet")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Complete tasks to see them here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
    }
    
    // MARK: - Helper Methods
    private func countTasks(for period: TimePeriod) -> Int {
        tasks.filter { task in
            guard let completedDate = task.completedDate else { return false }
            
            switch period {
            case .all:
                return true
            case .today:
                return Calendar.current.isDateInToday(completedDate)
            case .yesterday:
                return Calendar.current.isDateInYesterday(completedDate)
            case .thisWeek:
                return Calendar.current.isDate(completedDate, equalTo: Date(), toGranularity: .weekOfYear)
            case .lastWeek:
                guard let lastWeek = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: Date()) else { return false }
                return Calendar.current.isDate(completedDate, equalTo: lastWeek, toGranularity: .weekOfYear)
            case .thisMonth:
                return Calendar.current.isDate(completedDate, equalTo: Date(), toGranularity: .month)
            }
        }.count
    }
    
    private func uncompleteTask(_ task: Task) {
        withAnimation {
            task.isCompleted = false
            task.completedDate = nil
            try? modelContext.save()
        }
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            modelContext.delete(task)
            try? modelContext.save()
        }
    }
    
    private func clearAllCompleted() {
        withAnimation {
            for task in filteredTasks {
                modelContext.delete(task)
            }
            try? modelContext.save()
        }
    }
}

// MARK: - AnytimeView
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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            if filteredTasks.isEmpty {
                emptyStateView
            } else {
                tasksList
            }
        }
        .navigationTitle("Anytime")
        .navigationSubtitle("\(filteredTasks.count) task\(filteredTasks.count == 1 ? "" : "s") without dates")
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Backlog Tasks")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Tasks without due dates that you can work on anytime")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Schedule All") {
                    // Show a sheet to batch schedule tasks
                }
                .buttonStyle(BorderedButtonStyle())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Tasks List
    private var tasksList: some View {
        ScrollView {
            VStack(spacing: 8) {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task)
                }
            }
            .padding()
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "archivebox")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green.opacity(0.6), .teal.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Backlog Tasks")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Tasks without due dates will appear here")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
    }
}

// MARK: - Supporting Types
enum TimePeriod: String, CaseIterable, Identifiable {
    case all = "All"
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    
    var id: String { rawValue }
}

struct PeriodChip: View {
    let period: TimePeriod
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(period.rawValue)
                    .font(.system(size: 13, weight: .medium))
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 11, weight: .semibold))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .foregroundColor(isSelected ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
            
            Text(title)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CompletedTaskRow: View {
    let task: Task
    let onUncomplete: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onUncomplete) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Mark as incomplete")
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 14))
                    .strikethrough()
                    .foregroundColor(.secondary)
                
                if let completedDate = task.completedDate {
                    Text("Completed \(completedDate, style: .relative)")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
            .help("Delete permanently")
        }
        .padding(12)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

struct TaskStatistics {
    let tasks: [Task]
    
    var totalCompleted: Int {
        tasks.count
    }
    
    var currentStreak: Int {
        // Calculate current streak logic
        return 3
    }
    
    var averageCompletionTime: String {
        // Calculate average time between creation and completion
        return "2.5 days"
    }
    
    var bestDay: String {
        // Find day with most completions
        return "Monday"
    }
}
#endif
