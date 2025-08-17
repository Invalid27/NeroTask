// Views/macOS/AnytimeView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct AnytimeView: View {
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted && task.dueDate == nil && !task.isToday
    }) private var tasks: [Task]
    
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
        }
        .listStyle(.inset)
        .navigationTitle("Anytime")
        .navigationSubtitle("\(tasks.count) tasks")
    }
}
#endif
