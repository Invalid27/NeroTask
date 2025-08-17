// Views/ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var searchText = ""
    
    #if os(macOS)
    @State private var selectedView: SidebarItem? = .inbox
    @State private var showingQuickEntry = false
    @State private var selectedTask: Task?
    #endif
    
    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarView(selection: $selectedView)
        } detail: {
            DetailView(
                selectedView: selectedView,
                searchText: $searchText,
                selectedTask: $selectedTask,
                showingQuickEntry: $showingQuickEntry
            )
        }
        .navigationSplitViewStyle(.balanced)
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search")
        .sheet(isPresented: $showingQuickEntry) {
            QuickEntryView()
        }
        .sheet(item: $selectedTask) { task in
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
