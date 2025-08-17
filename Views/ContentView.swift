// Views/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var appState: AppState
    
    #if os(macOS)
    // Using the SidebarItem from Models/SidebarItem.swift
    @State private var selectedView: SidebarItem? = .inbox
    #endif
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selection: $selectedView)
        } detail: {
            DetailView(
                selectedView: selectedView,
                searchText: $appState.searchText,
                selectedTask: $appState.selectedTask,
                showingQuickEntry: $appState.showingQuickEntry
            )
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
            
            CompletedView()
                .tabItem {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                }
        }
        .searchable(text: $appState.searchText, prompt: "Search")
        .sheet(isPresented: $appState.showingQuickEntry) {
            QuickEntryView()
        }
        #endif
    }
}
