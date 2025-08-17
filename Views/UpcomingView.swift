// Views/UpcomingView.swift
import SwiftUI
import SwiftData

struct UpcomingView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate != nil
    }, sort: \Task.dueDate) private var tasks: [Task]
    
    @State private var selection: UUID?
    
    var filteredTasks: [Task] {
        #if os(macOS)
        if appState.searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText)
        }
        #else
        return tasks
        #endif
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(filteredTasks) { task in
                TaskRowView(
                    task: task,
                    selectedTask: $appState.selectedTask,
                    expandedTask: $appState.expandedTask,
                    isSelected: selection == task.id
                )
                .tag(task.id)
                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                .listRowSeparator(.hidden)
            }
        }
        #if os(macOS)
        .listStyle(.inset(alternatesRowBackgrounds: false))
        #else
        .listStyle(.plain)
        #endif
        .navigationTitle("Upcoming")
        #if os(macOS)
        .navigationSubtitle("\(tasks.count) scheduled")
        #endif
    }
}
