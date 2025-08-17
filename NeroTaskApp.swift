// NeroTaskApp.swift
import SwiftUI
import SwiftData

@main
struct NeroTaskApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Task.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(minWidth: 800, minHeight: 600)
                #endif
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified)
        #endif
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
