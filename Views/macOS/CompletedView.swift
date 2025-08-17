// Views/macOS/CompletedView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct CompletedView: View {
    @Query(filter: #Predicate<Task> { $0.isCompleted },
           sort: \Task.completedDate,
           order: .reverse) private var tasks: [Task]
    
    @State private var selection = Set<Task>()
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
                TaskRowView(task: task, selectedTask: $selectedTask)
                    .listRowSeparator(.hidden)
                    .tag(task)
            }
            .onDelete(perform: deleteTasks)
        }
        .listStyle(.inset)
        .navigationTitle("Completed")
        .navigationSubtitle("\(tasks.count) completed")
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            filteredTasks[index].modelContext?.delete(filteredTasks[index])
        }
    }
}
#endif
