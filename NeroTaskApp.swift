// NeroTaskApp.swift
import SwiftUI
import SwiftData

@main
struct NeroTaskApp: App {
    @StateObject private var appState = AppState()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                #if os(macOS)
                .frame(minWidth: 900, minHeight: 600)
                #endif
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Task") {
                    appState.showingQuickEntry = true
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandMenu("Task") {
                Button("Mark as Today") {
                    appState.markSelectedAsToday()
                }
                .keyboardShortcut("t", modifiers: .command)
                .disabled(appState.selectedTasks.isEmpty)
                
                Button("Complete Task") {
                    appState.completeSelected()
                }
                .keyboardShortcut("k", modifiers: .command)
                .disabled(appState.selectedTasks.isEmpty)
                
                Divider()
                
                Button("Delete Task") {
                    appState.deleteSelected()
                }
                .keyboardShortcut(.delete, modifiers: .command)
                .disabled(appState.selectedTasks.isEmpty)
            }
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        #endif
    }
}

// MARK: - App State
class AppState: ObservableObject {
    @Published var selectedTask: Task?
    @Published var selectedTasks: Set<UUID> = []
    @Published var showingQuickEntry = false
    @Published var searchText = ""
    
    // Note: We're NOT declaring selectedView here to avoid conflicts
    // Let each platform handle its own navigation
    
    func markSelectedAsToday() {
        // Implementation will be added when we have access to model context
    }
    
    func completeSelected() {
        // Implementation will be added when we have access to model context
    }
    
    func deleteSelected() {
        // Implementation will be added when we have access to model context
    }
}
