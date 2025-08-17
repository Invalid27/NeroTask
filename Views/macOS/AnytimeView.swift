// Views/macOS/AnytimeView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct AnytimeView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate == nil && !task.isToday
    }) private var tasks: [Task]
    
    @State private var selection: UUID?
    
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
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .navigationTitle("Anytime")
        .navigationSubtitle("\(tasks.count) tasks")
    }
}
#endif
