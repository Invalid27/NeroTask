// Views/macOS/CompletedView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct CompletedView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    @Query(filter: #Predicate<Task> { $0.isCompleted },
           sort: \Task.completedDate,
           order: .reverse) private var tasks: [Task]
    
    @State private var selection: UUID?
    @State private var expandedTask: Task?
    @Binding var selectedTask: Task?
    var searchText: String = ""
    
    init(searchText: String = "", selectedTask: Binding<Task?>? = nil) {
        self.searchText = searchText
        self._selectedTask = selectedTask ?? .constant(nil)
    }
    
    var filteredTasks: [Task] {
        if searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.notes.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        List(selection: $selection) {
            ForEach(filteredTasks) { task in
                TaskRowView(
                    task: task,
                    selectedTask: $selectedTask,
                    expandedTask: $expandedTask,
                    isSelected: selection == task.id
                )
                .tag(task.id)
                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(.inset(alternatesRowBackgrounds: false))
        .navigationTitle("Completed")
        .navigationSubtitle("\(tasks.count) completed")
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTasks[index])
        }
    }
}
#endif
