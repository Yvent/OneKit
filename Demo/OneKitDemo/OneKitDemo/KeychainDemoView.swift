//
//  KeychainDemoView.swift
//  OneKitDemo
//
//  Created by OneKit
//

import SwiftUI
import OneKitCore

// MARK: - 1️⃣ Define Secure Storage (Do this once!)

enum SecureStorage {
    @KeychainStored("authToken")
    static var authToken: String

    @KeychainStored("refreshToken")
    static var refreshToken: String?

    @KeychainStored("userPrivateKey")
    static var privateKey: Data
}

// MARK: - 2️⃣ Use in Your View!

struct KeychainDemoView: View {
    // Local state to trigger view updates
    @State private var authToken: String = ""
    @State private var refreshToken: String = ""
    @State private var privateKeyData: Data = Data()
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        List {
            // ✨ Simple: Just use SecureStorage.xxx
            Section {
                HStack {
                    Text("Auth Token")
                    TextField("Enter token", text: $authToken)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: authToken) { _, newValue in
                            SecureStorage.authToken = newValue
                        }
                }

                HStack {
                    Text("Refresh Token")
                    TextField("Enter refresh token", text: $refreshToken)
                        .textFieldStyle(.roundedBorder)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: refreshToken) { _, newValue in
                            SecureStorage.refreshToken = newValue.isEmpty ? nil : newValue
                        }
                }

                Button("Generate Private Key") {
                    // Generate a random private key
                    privateKeyData = generateRandomKey()
                    SecureStorage.privateKey = privateKeyData
                    alertMessage = "Private key generated and stored securely!"
                    showingAlert = true
                }

                Button("Delete Private Key") {
                    KeychainManager.delete(key: "userPrivateKey")
                    privateKeyData = Data()
                    alertMessage = "Private key deleted from Keychain"
                    showingAlert = true
                }
                .foregroundColor(.red)

            } header: {
                Text("✨ Live Demo")
            } footer: {
                Text("Data is encrypted and stored securely in Keychain!")
            }

            // Show current values
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    infoRow("Auth Token", authToken.isEmpty ? "(empty)" : authToken)
                    infoRow("Refresh Token", refreshToken.isEmpty ? "(nil)" : refreshToken)
                    infoRow("Private Key", privateKeyData.isEmpty ? "(empty)" : "\(privateKeyData.count) bytes")
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
                        enum SecureStorage {
                            @KeychainStored("authToken")
                            static var authToken: String

                            @KeychainStored("refreshToken")
                            static var refreshToken: String?
                        }
                        """
                    )

                    CodeExample(
                        title: "Step 2: Use",
                        code: """
                        // Save (encrypted automatically!)
                        SecureStorage.authToken = "my_token"

                        // Read
                        let token = SecureStorage.authToken

                        // Delete
                        KeychainManager.delete(key: "authToken")
                        """
                    )

                    Divider()
                        .padding(.vertical, 4)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("🔐 Why Keychain?")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)

                        Text("• Encrypted storage")
                            .font(.caption)
                        Text("• Persists across app reinstalls")
                            .font(.caption)
                        Text("• Perfect for tokens, passwords, keys")
                            .font(.caption)
                    }
                }
            } header: {
                Text("How It Works")
            }

            // Security features
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    featureRow("🔒", "Encrypted", "Data is encrypted by iOS")
                    featureRow("🔑", "Secure", "Protected by device lock")
                    featureRow("☁️", "Sync", "Optional iCloud sync available")
                    featureRow("🛡️", "Access Control", "Configurable security levels")
                }
            } header: {
                Text("Security Features")
            }
        }
        .navigationTitle("Keychain")
        .alert("Status", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            // Load initial values from SecureStorage
            authToken = SecureStorage.authToken
            refreshToken = SecureStorage.refreshToken ?? ""
            privateKeyData = SecureStorage.privateKey
        }
    }

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text("\(label):")
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .foregroundStyle(.primary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
    }

    private func featureRow(_ icon: String, _ title: String, _ description: String) -> some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func generateRandomKey() -> Data {
        // Generate 32 random bytes (256 bits)
        var key = Data(count: 32)
        _ = key.withUnsafeMutableBytes { bytes in
            SecRandomCopyBytes(kSecRandomDefault, 32, bytes.baseAddress!)
        }
        return key
    }
}

#Preview {
    NavigationStack {
        KeychainDemoView()
    }
}
