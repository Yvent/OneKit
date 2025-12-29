//
//  UserDefaultsDemoView.swift
//  OneKitDemo
//
//  Created by OneKit
//

import SwiftUI
import OneKitCore

// MARK: - 1️⃣ Define Settings (Do this once!)

enum AppSettings {
    @UserDefault("username", default: "")
    static var username: String

    @UserDefault("isPremium", default: false)
    static var isPremium: Bool

    @UserDefault("theme", default: .light)
    static var theme: Theme
}

enum Theme: String, UserDefaultsSerializable {
    case light
    case dark
    case system
}

// MARK: - 2️⃣ Use in Your View!

struct UserDefaultsDemoView: View {
    // Local state to trigger view updates
    @State private var username: String = ""
    @State private var isPremium: Bool = false
    @State private var theme: Theme = .light

    var body: some View {
        List {
            // ✨ Simple: Just use AppSettings.xxx
            Section {
                HStack {
                    Text("Username")
                    TextField("Enter username", text: $username)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: username) { _, newValue in
                            AppSettings.username = newValue
                        }
                }

                Toggle("Premium User", isOn: $isPremium)
                    .onChange(of: isPremium) { _, newValue in
                        AppSettings.isPremium = newValue
                    }

                Picker("Theme", selection: $theme) {
                    Text("Light").tag(Theme.light)
                    Text("Dark").tag(Theme.dark)
                    Text("System").tag(Theme.system)
                }
                .onChange(of: theme) { _, newValue in
                    AppSettings.theme = newValue
                }

            } header: {
                Text("✨ Live Demo")
            } footer: {
                Text("Changes are saved immediately - no Save button needed!")
            }

            // Show current values
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Username", username)
                    infoRow("Premium", "\(isPremium)")
                    infoRow("Theme", "\(theme.rawValue)")
                }
                .font(.system(.body, design: .monospaced))
            } header: {
                Text("Current Values")
            }

            // Explain why enum
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    CodeExample(
                        title: "Step 1: Define",
                        code: """
                        enum AppSettings {
                            @UserDefault("username", default: "")
                            static var username: String
                        }
                        """
                    )

                    CodeExample(
                        title: "Step 2: Use",
                        code: """
                        // Read
                        let name = AppSettings.username

                        // Write (saved immediately!)
                        AppSettings.username = "John"
                        """
                    )

                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("💡 Why static enum?")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        Text("• Shared across all views")
                            .font(.caption)
                        Text("• Clean namespace (AppSettings.xxx)")
                            .font(.caption)
                        Text("• Works with SwiftUI binding")
                            .font(.caption)
                    }
                }
            } header: {
                Text("How It Works")
            }
        }
        .navigationTitle("UserDefaults")
        .onAppear {
            // Load initial values from AppSettings
            username = AppSettings.username
            isPremium = AppSettings.isPremium
            theme = AppSettings.theme
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        UserDefaultsDemoView()
    }
}
