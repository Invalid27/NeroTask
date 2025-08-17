// Views/macOS/SettingsView.swift
import SwiftUI

#if os(macOS)
struct SettingsView: View {
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
    @AppStorage("defaultDueTime") private var defaultDueTimeInterval: Double = Date().timeIntervalSinceReferenceDate
    @AppStorage("confirmBeforeDelete") private var confirmBeforeDelete: Bool = true
    @AppStorage("showCompletedInLists") private var showCompletedInLists: Bool = false
    
    private var defaultDueTime: Binding<Date> {
        Binding(
            get: { Date(timeIntervalSinceReferenceDate: defaultDueTimeInterval) },
            set: { defaultDueTimeInterval = $0.timeIntervalSinceReferenceDate }
        )
    }
    
    var body: some View {
        Form {
            DatePicker("Default due time:", selection: defaultDueTime, displayedComponents: .hourAndMinute)
            
            Toggle("Show completed tasks in lists", isOn: $showCompletedInLists)
            
            Toggle("Confirm before deleting tasks", isOn: $confirmBeforeDelete)
        }
        .padding()
    }
}

struct AppearanceSettingsView: View {
    @AppStorage("accentColor") private var accentColor: String = "blue"
    @AppStorage("fontSize") private var fontSize: Double = 13.0
    
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
