// Views/macOS/SettingsView.swift
import SwiftUI

#if os(macOS)
struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            AppearanceSettingsView()
                .tabItem {
                    Label("Appearance", systemImage: "paintbrush")
                }
            
            KeyboardSettingsView()
                .tabItem {
                    Label("Keyboard", systemImage: "keyboard")
                }
        }
        .frame(width: 500, height: 350)
    }
}

// MARK: - General Settings
struct GeneralSettingsView: View {
    @AppStorage("defaultDueTimeHour") private var defaultDueTimeHour: Int = 9
    @AppStorage("defaultDueTimeMinute") private var defaultDueTimeMinute: Int = 0
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true
    @AppStorage("showCompletedInLists") private var showCompletedInLists: Bool = false
    @AppStorage("autoMoveOverdueToToday") private var autoMoveOverdueToToday: Bool = false
    @AppStorage("playSoundOnComplete") private var playSoundOnComplete: Bool = true
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Default due time:")
                    Picker("Hour", selection: $defaultDueTimeHour) {
                        ForEach(0..<24) { hour in
                            Text(String(format: "%02d", hour)).tag(hour)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 60)
                    
                    Text(":")
                    
                    Picker("Minute", selection: $defaultDueTimeMinute) {
                        ForEach([0, 15, 30, 45], id: \.self) { minute in
                            Text(String(format: "%02d", minute)).tag(minute)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .frame(width: 60)
                }
                
                Toggle("Show completed tasks in lists", isOn: $showCompletedInLists)
                
                Toggle("Confirm before deleting tasks", isOn: $confirmBeforeDelete)
                
                Toggle("Automatically move overdue tasks to Today", isOn: $autoMoveOverdueToToday)
                
                Toggle("Play sound when completing tasks", isOn: $playSoundOnComplete)
            } header: {
                Text("Task Management")
                    .font(.headline)
            }
        }
        .padding()
    }
}

// MARK: - Appearance Settings
struct AppearanceSettingsView: View {
    @AppStorage("accentColor") private var accentColor: String = "blue"
    @AppStorage("fontSize") private var fontSize: Double = 14.0
    @AppStorage("useCompactMode") private var useCompactMode: Bool = false
    @AppStorage("showTaskNumbers") private var showTaskNumbers: Bool = false
    @AppStorage("animationsEnabled") private var animationsEnabled: Bool = true
    
    var body: some View {
        Form {
            Section {
                Picker("Accent color:", selection: $accentColor) {
                    HStack {
                        Circle().fill(Color.blue).frame(width: 10, height: 10)
                        Text("Blue")
                    }.tag("blue")
                    HStack {
                        Circle().fill(Color.purple).frame(width: 10, height: 10)
                        Text("Purple")
                    }.tag("purple")
                    HStack {
                        Circle().fill(Color.pink).frame(width: 10, height: 10)
                        Text("Pink")
                    }.tag("pink")
                    HStack {
                        Circle().fill(Color.red).frame(width: 10, height: 10)
                        Text("Red")
                    }.tag("red")
                    HStack {
                        Circle().fill(Color.orange).frame(width: 10, height: 10)
                        Text("Orange")
                    }.tag("orange")
                    HStack {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Green")
                    }.tag("green")
                }
                .pickerStyle(MenuPickerStyle())
                
                HStack {
                    Text("Font size:")
                    Slider(value: $fontSize, in: 11...18, step: 1)
                    Text("\(Int(fontSize))pt")
                        .monospacedDigit()
                        .frame(width: 40)
                }
                
                Toggle("Use compact mode", isOn: $useCompactMode)
                    .help("Reduces spacing between tasks")
                
                Toggle("Show task numbers in sidebar", isOn: $showTaskNumbers)
                
                Toggle("Enable animations", isOn: $animationsEnabled)
            } header: {
                Text("Visual Preferences")
                    .font(.headline)
            }
        }
        .padding()
    }
}

// MARK: - Keyboard Settings
struct KeyboardSettingsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Keyboard Shortcuts")
                .font(.headline)
            
            Grid(alignment: .leading, horizontalSpacing: 40, verticalSpacing: 12) {
                GridRow {
                    Text("New Task")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘N")
                }
                
                GridRow {
                    Text("Quick Entry")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘⇧N")
                }
                
                GridRow {
                    Text("Search")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘F")
                }
                
                GridRow {
                    Text("Complete Task")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘K")
                }
                
                GridRow {
                    Text("Mark as Today")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘T")
                }
                
                GridRow {
                    Text("Delete Task")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘⌫")
                }
                
                GridRow {
                    Text("Edit Task")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘E")
                }
                
                GridRow {
                    Text("Duplicate Task")
                        .gridColumnAlignment(.trailing)
                    KeyboardShortcutView(keys: "⌘D")
                }
            }
            
            Spacer()
            
            Text("Tip: Press and hold ⌘ in the app to see available shortcuts")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct KeyboardShortcutView: View {
    let keys: String
    
    var body: some View {
        Text(keys)
            .font(.system(size: 12, weight: .medium, design: .monospaced))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(4)
    }
}
#endif
