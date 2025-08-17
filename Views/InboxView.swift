// Views/InboxView.swift
import SwiftUI
import SwiftData

struct InboxView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    @Query(filter: #Predicate<Task> { task in
        !task.isCompleted
    }, sort: [
        SortDescriptor(\.priority, order: .reverse),
        SortDescriptor(\.createdDate, order: .reverse)
    ]) private var tasks: [Task]
    
    @State private var newTaskTitle = ""
    @State private var showingFilters = false
    @FocusState private var isInputFocused: Bool
    
    var filteredTasks: [Task] {
        if appState.searchText.isEmpty {
            return tasks
        }
        return tasks.filter {
            $0.title.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.notes.localizedCaseInsensitiveContains(appState.searchText) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(appState.searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Task list
            if filteredTasks.isEmpty {
                emptyStateView
            } else {
                taskListView
            }
        }
        .navigationTitle("Inbox")
        #if os(macOS)
        .navigationSubtitle("\(filteredTasks.count) task\(filteredTasks.count == 1 ? "" : "s")")
        .toolbar {
            ToolbarItemGroup {
                Button(action: { showingFilters.toggle() }) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .help("Filter tasks")
                }
                
                Button(action: { appState.showingQuickEntry = true }) {
                    Image(systemName: "plus")
                        .help("New task (⌘N)")
                }
            }
        }
        #endif
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                TextField("Add a new task...", text: $newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 15))
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
                
                if !newTaskTitle.isEmpty {
                    Button("Add") {
                        addTask()
                    }
                    .buttonStyle(BorderedProminentButtonStyle())
                    .controlSize(.small)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            Divider()
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
    }
    
    // MARK: - Task List View
    private var taskListView: some View {
        ScrollViewReader { proxy in
            List(selection: $appState.selectedTasks) {
                ForEach(filteredTasks) { task in
                    TaskRowView(task: task)
                        .id(task.id)
                        .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .transition(.asymmetric(
                            insertion: .push(from: .top).combined(with: .opacity),
                            removal: .push(from: .bottom).combined(with: .opacity)
                        ))
                }
                .onDelete(perform: deleteTasks)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: filteredTasks)
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("Your Inbox is Empty")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Add a task above to get started")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            
            Button(action: { isInputFocused = true }) {
                Label("Add Your First Task", systemImage: "plus.circle.fill")
                    .font(.system(size: 15, weight: .medium))
            }
            .buttonStyle(BorderedProminentButtonStyle())
            .controlSize(.large)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
    }
    
    // MARK: - Actions
    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            let newTask = Task(title: newTaskTitle)
            modelContext.insert(newTask)
            newTaskTitle = ""
            
            do {
                try modelContext.save()
            } catch {
                print("Error saving task: \(error)")
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
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
}
