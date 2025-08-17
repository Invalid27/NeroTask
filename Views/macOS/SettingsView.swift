// Views/macOS/SettingsView.swift
import SwiftUI

#if os(macOS)
struct SettingsView: View {
    @AppStorage("defaultDueTime") private var defaultDueTime = Date()
    @AppStorage("showCompletedInLists") private var showCompletedInLists = false
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete = true
    
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
        }
        .frame(width: 450, height: 250)
    }
}

struct GeneralSettingsView: View {
    @AppStorage("defaultDueTime") private var defaultDueTime = Date()
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete = true
    @AppStorage("showCompletedInLists") private var showCompletedInLists = false
    
    var body: some View {
        Form {
            DatePicker("Default due time:", selection: $defaultDueTime, displayedComponents: .hourAndMinute)
            
            Toggle("Show completed tasks in lists", isOn: $showCompletedInLists)
            
            Toggle("Confirm before deleting tasks", isOn: $confirmBeforeDelete)
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("accentColor") private var accentColor = "blue"
    @AppStorage("fontSize") private var fontSize = 13.0
    
    var body: some View {
        Form {
            Picker("Accent color:", selection: $accentColor) {
                Text("Blue").tag("blue")
                Text("Purple").tag("purple")
                Text("Pink").tag("pink")
                Text("Red").tag("red")
                Text("Orange").tag("orange")
                Text("Yellow").tag("yellow")
                Text("Green").tag("green")
            }
            
            HStack {
                Text("Font size:")
                Slider(value: $fontSize, in: 10...18, step: 1)
                Text("\(Int(fontSize))pt")
                    .monospacedDigit()
                    .frame(width: 40)
            }
        }
        .padding()
    }
}
#endif
