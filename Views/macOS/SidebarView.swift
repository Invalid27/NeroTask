// Views/macOS/SidebarView.swift
import SwiftUI
import SwiftData

#if os(macOS)
struct SidebarView: View {
    @Binding var selection: SidebarItem?
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Task> { !$0.isCompleted }) private var incompleteTasks: [Task]
    @Query(filter: #Predicate<Task> { $0.isToday && !$0.isCompleted }) private var todayTasks: [Task]
    
    var body: some View {
        List(selection: $selection) {
            Section {
                ForEach(SidebarItem.allCases) { item in
                    Label {
                        HStack {
                            Text(item.rawValue)
                            Spacer()
                            if item == .inbox {
                                Text("\(incompleteTasks.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if item == .today {
                                Text("\(todayTasks.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } icon: {
                        Image(systemName: item.icon)
                    }
                    .tag(item)
                }
            }
            
            Section("Projects") {
                // Future: Add projects here
                Label("Work", systemImage: "briefcase")
                Label("Personal", systemImage: "house")
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Tasks")
        .frame(minWidth: 200)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
            }
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}
#endif
