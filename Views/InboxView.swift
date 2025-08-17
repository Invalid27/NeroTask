// Views/InboxView.swift
import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted
    }, sort: \Task.createdDate, order: .reverse) private var tasks: [Task]
    
    @State private var newTaskTitle = ""
    @FocusState private var isInputFocused: Bool
    @State private var selection: UUID?
    @State private var expandedTask: Task?
    
    #if os(macOS)
    var searchText: String
    @Binding var selectedTask: Task?
    
    init(searchText: String = "", selectedTask: Binding<Task?>) {
        self.searchText = searchText
        self._selectedTask = selectedTask
    }
    #else
    let searchText: String = ""
    @State private var selectedTask: Task?
    
    init() {}
    #endif
    
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
        VStack(spacing: 0) {
            // Header with quick add
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.system(size: 20))
                    
                    TextField("New Task", text: $newTaskTitle)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14))
                        .focused($isInputFocused)
                        .onSubmit {
                            addTask()
                        }
                        #if os(macOS)
                        .onExitCommand {
                            newTaskTitle = ""
                            isInputFocused = false
                        }
                        #endif
                }
                .padding()
                
                Divider()
            }
            #if os(macOS)
            .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            #endif
            
            // Task list
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
            #if os(macOS)
            .listStyle(.inset(alternatesRowBackgrounds: false))
            #else
            .listStyle(.plain)
            #endif
        }
        .navigationTitle("Inbox")
        #if os(macOS)
        .navigationSubtitle("\(tasks.count) tasks")
        #endif
    }
    
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        let newTask = Task(title: newTaskTitle)
        modelContext.insert(newTask)
        newTaskTitle = ""
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving task: \(error)")
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredTasks[index])
        }
        do {
            try modelContext.save()
        } catch {
            print("Error deleting tasks: \(error)")
        }
    }
}
