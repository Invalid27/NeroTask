// Views/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 240, max: 300)
        } detail: {
            DetailView()
        }
        .navigationSplitViewStyle(.balanced)
        .searchable(text: $appState.searchText, placement: .sidebar, prompt: "Search tasks...")
        .sheet(isPresented: $appState.showingQuickEntry) {
            QuickEntryView()
                .environmentObject(appState)
        }
        .sheet(item: $appState.selectedTask) { task in
            TaskEditView(task: task)
                .environmentObject(appState)
        }
        #else
        TabView {
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }
            
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "star.fill")
                }
            
            UpcomingView()
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
            
            CompletedView()
                .tabItem {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                }
        }
        .searchable(text: $appState.searchText, prompt: "Search tasks...")
        .sheet(isPresented: $appState.showingQuickEntry) {
            QuickEntryView()
                .environmentObject(appState)
        }
        #endif
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(AppState())
        .modelContainer(for: Task.self, inMemory: true)
}
