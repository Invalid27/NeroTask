// Views/TodayView.swift
import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { task in
        task.isToday && !task.isCompleted
    }, sort: [
        SortDescriptor(\.priority, order: .reverse),
        SortDescriptor(\.createdDate)
    ]) private var todayTasks: [Task]
    
    @Query(filter: #Predicate<Task> { task in
        task.isCompleted && task.completedDate != nil
    }, sort: \Task.completedDate, order: .reverse)
    private var recentlyCompleted: [Task]
    
    var todaysCompletedTasks: [Task] {
        recentlyCompleted.filter { task in
            guard let completedDate = task.completedDate else { return false }
            return Calendar.current.isDateInToday(completedDate)
        }
    }
    
    var filteredTasks: [Task] {
        if appState.searchText.isEmpty {
            return todayTasks
        }
        return todayTasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerView
                
                // Today's Focus
                if !filteredTasks.isEmpty {
                    todaysFocusSection
                }
                
                // Completed Today
                if !todaysCompletedTasks.isEmpty {
                    completedTodaySection
                }
                
                // Empty State
                if filteredTasks.isEmpty && todaysCompletedTasks.isEmpty {
                    emptyStateView
                }
            }
            .padding(20)
        }
        .navigationTitle("Today")
        #if os(macOS)
        .navigationSubtitle(subtitle)
        .toolbar {
            ToolbarItemGroup {
                Button(action: clearCompleted) {
                    Label("Clear Completed", systemImage: "trash")
                }
                .disabled(todaysCompletedTasks.isEmpty)
            }
        }
        #endif
    }
    
    private var subtitle: String {
        let taskCount = filteredTasks.count
        let completedCount = todaysCompletedTasks.count
        
        if taskCount == 0 && completedCount > 0 {
            return "All done! 🎉"
        } else if taskCount == 1 {
            return "1 task remaining"
        } else {
            return "\(taskCount) tasks remaining"
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(greeting)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Spacer()
                
                Text(currentDate)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Text(motivationalQuote)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .italic()
        }
        .padding(.bottom, 8)
    }
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12:
            return "Good Morning ☀️"
        case 12..<17:
            return "Good Afternoon 🌤"
        default:
            return "Good Evening 🌙"
        }
    }
    
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private var motivationalQuote: String {
        let quotes = [
            "Focus on what matters most",
            "One task at a time",
            "Progress over perfection",
            "Today is full of possibilities",
            "Small steps, big results"
        ]
        return quotes.randomElement() ?? ""
    }
    
    // MARK: - Today's Focus Section
    private var todaysFocusSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Today's Focus", systemImage: "star.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.orange)
                
                Spacer()
                
                if filteredTasks.count > 0 {
                    ProgressView(value: Double(todaysCompletedTasks.count),
                                total: Double(todaysCompletedTasks.count + filteredTasks.count))
                        .progressViewStyle(GaugeProgressStyle())
                        .frame(width: 100)
                }
            }
            
            VStack(spacing: 8) {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task)
                        .transition(.asymmetric(
                            insertion: .push(from: .leading).combined(with: .opacity),
                            removal: .push(from: .trailing).combined(with: .opacity)
                        ))
                }
            }
        }
    }
    
    // MARK: - Completed Today Section
    private var completedTodaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Completed Today", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.green)
                
                Spacer()
                
                Text("\(todaysCompletedTasks.count)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            
            VStack(spacing: 8) {
                ForEach(todaysCompletedTasks) { task in
                    CompletedTaskRow(task: task)
                }
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.orange.opacity(0.5), .yellow.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("No Tasks for Today")
                    .font(.system(size: 20, weight: .semibold))
                
                Text("Add tasks from your inbox or create new ones")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 12) {
                Button(action: { appState.selectedView = .inbox }) {
                    Label("Go to Inbox", systemImage: "tray")
                }
                .buttonStyle(BorderedButtonStyle())
                
                Button(action: { appState.showingQuickEntry = true }) {
                    Label("New Task", systemImage: "plus")
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    // MARK: - Actions
    private func clearCompleted() {
        withAnimation {
            for task in todaysCompletedTasks {
                task.isToday = false
            }
            try? modelContext.save()
        }
    }
}

// MARK: - Completed Task Row
struct CompletedTaskRow: View {
    let task: Task
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .strikethrough()
                
                if let completedDate = task.completedDate {
                    Text("Completed \(completedDate, style: .relative) ago")
                        .font(.system(size: 11))
                        .foregroundColor(.tertiary)
                }
            }
            
            Spacer()
            
            Button(action: { undoComplete() }) {
                Text("Undo")
                    .font(.system(size: 11))
                    .foregroundColor(.blue)
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(0.6)
            .onHover { hovering in
                withAnimation {
                    // Show on hover
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.green.opacity(0.05))
        .cornerRadius(8)
    }
    
    private func undoComplete() {
        withAnimation {
            task.isCompleted = false
            task.completedDate = nil
            try? modelContext.save()
        }
    }
}

// MARK: - Gauge Progress Style
struct GaugeProgressStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(
                        LinearGradient(
                            colors: [.green, .mint],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 8)
                    .animation(.spring(response: 0.3), value: configuration.fractionCompleted)
            }
        }
        .frame(height: 8)
    }
}
