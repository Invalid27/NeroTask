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
                .background(VisualEffectBlur())
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
                
                Button("Complete Task") {
                    appState.completeSelected()
                }
                .keyboardShortcut("k", modifiers: .command)
                
                Divider()
                
                Button("Delete Task") {
                    appState.deleteSelected()
                }
                .keyboardShortcut(.delete, modifiers: .command)
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
    @Published var selectedView: SidebarItem? = .inbox
    
    func markSelectedAsToday() {
        // Implementation for marking selected tasks as today
    }
    
    func completeSelected() {
        // Implementation for completing selected tasks
    }
    
    func deleteSelected() {
        // Implementation for deleting selected tasks
    }
}

// MARK: - Visual Effect Background (macOS)
#if os(macOS)
struct VisualEffectBlur: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .sidebar
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
#endif
