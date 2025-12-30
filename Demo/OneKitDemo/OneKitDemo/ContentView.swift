//
//  ContentView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Core Features") {
                    NavigationLink("Device Info", destination: DeviceInfoView())
                    NavigationLink("Permission Manager", destination: PermissionDemoView())
                    NavigationLink("App Info", destination: AppInfoView())
                }

                Section("UI Components") {
                    NavigationLink("Gradient Playground", destination: GradientPlaygroundView())
                    NavigationLink("Haptic Feedback", destination: HapticDemoView())
                }

                Section("Utilities") {
                    NavigationLink("UserDefaults", destination: UserDefaultsDemoView())
                    NavigationLink("String Extensions", destination: StringExtensionsView())
                    NavigationLink("Date Extensions", destination: DateExtensionsView())
                }

                Section("UI Components") {
                    NavigationLink("Components", destination: ComponentsDemoView())
                }
            }
            .navigationTitle("OneKit Demo")
        }
    }
}

#Preview {
    ContentView()
}
