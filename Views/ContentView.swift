// Views/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selection: $appState.selectedView)
        } detail: {
            DetailView()  // No parameters needed - it gets AppState from environment
        }
        .navigationSplitViewStyle(.balanced)
        .searchable(text: $appState.searchText, placement: .toolbar, prompt: "Search")
        .sheet(isPresented: $appState.showingQuickEntry) {
            QuickEntryView()
        }
        .sheet(item: $appState.selectedTask) { task in
            TaskEditView(task: task)
        }
        #else
        TabView {
            InboxView()
                .tabItem {
                    Label("Inbox", systemImage: "tray")
                }
            
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "star")
                }
            
            UpcomingView()
                .tabItem {
                    Label("Upcoming", systemImage: "calendar")
                }
        }
        #endif
    }
}
