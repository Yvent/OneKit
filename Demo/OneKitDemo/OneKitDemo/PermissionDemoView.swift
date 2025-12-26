//
//  PermissionDemoView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitCore

struct PermissionDemoView: View {
    @State private var cameraStatus: PermissionStatus = .notDetermined
    @State private var microphoneStatus: PermissionStatus = .notDetermined
    @State private var photoLibraryStatus: PermissionStatus = .notDetermined

    @State private var autoShowSettingsAlert = true
    @State private var useCustomConfiguration = false

    var body: some View {
        List {
            // Configuration Section
            Section {
                Toggle("Auto Show Settings Alert", isOn: $autoShowSettingsAlert)
                    .onChange(of: autoShowSettingsAlert) { _, newValue in
                        PermissionManager.autoShowSettingsAlert = newValue
                    }

                Toggle("Use Custom Configuration", isOn: $useCustomConfiguration)
                    .onChange(of: useCustomConfiguration) { _, newValue in
                        if newValue {
                            // Example: Complete custom configuration with Chinese text
                            PermissionManager.customAlertConfiguration = [
                                .camera: (
                                    title: "需要相机权限",
                                    message: "请在设置中开启相机访问权限",
                                    cancelButton: "取消",
                                    openSettingsButton: "去设置"
                                ),
                                .microphone: (
                                    title: "需要麦克风权限",
                                    message: "请在设置中开启麦克风访问权限",
                                    cancelButton: "取消",
                                    openSettingsButton: "去设置"
                                ),
                                .photoLibrary: (
                                    title: "需要相册权限",
                                    message: "请在设置中开启相册访问权限",
                                    cancelButton: "取消",
                                    openSettingsButton: "去设置"
                                )
                            ]
                        } else {
                            // Clear custom configuration
                            PermissionManager.customAlertConfiguration = nil
                        }
                    }
            } header: {
                Text("Configuration")
            } footer: {
                Text("Configure how permission alerts are shown")
            }

            Section {
                PermissionRow(
                    title: "Camera",
                    status: cameraStatus,
                    requestAction: {
                        await requestCameraPermission()
                    }
                )

                PermissionRow(
                    title: "Microphone",
                    status: microphoneStatus,
                    requestAction: {
                        await requestMicrophonePermission()
                    }
                )

                PermissionRow(
                    title: "Photo Library",
                    status: photoLibraryStatus,
                    requestAction: {
                        await requestPhotoLibraryPermission()
                    }
                )
            } header: {
                Text("Individual Permissions")
            }

            Section {
                Button("Request All Permissions") {
                    Task {
                        await requestAllPermissions()
                    }
                }
                .disabled(allPermissionsGranted)
            } header: {
                Text("Batch Operations")
            } footer: {
                Text("Request multiple permissions at once")
            }

            // Code Examples Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    CodeExample(
                        title: "Disable Auto Alert",
                        code: """
                        PermissionManager.autoShowSettingsAlert = false
                        """
                    )

                    CodeExample(
                        title: "Custom Alert Configuration",
                        code: """
                        PermissionManager.customAlertConfiguration = [
                            .camera: (
                                title: "需要相机权限",
                                message: "请在设置中开启相机访问权限",
                                cancelButton: "取消",
                                openSettingsButton: "去设置"
                            )
                        ]
                        """
                    )

                    CodeExample(
                        title: "Custom Handler",
                        code: """
                        PermissionManager.permissionDeniedHandler = {
                            type in
                            // Show custom alert
                            return true  // Handled
                        }
                        """
                    )
                }
            } header: {
                Text("Code Examples")
            }
        }
        .navigationTitle("Permissions")
        .onAppear {
            Task {
                await refreshPermissionStatuses()
            }
        }
        .onDisappear {
            // Reset configuration when leaving
            PermissionManager.autoShowSettingsAlert = true
            PermissionManager.customAlertConfiguration = nil
        }
    }

    private var allPermissionsGranted: Bool {
        cameraStatus == .authorized &&
        microphoneStatus == .authorized &&
        photoLibraryStatus == .authorized
    }

    private func requestCameraPermission() async {
        let result = await PermissionManager.camera.request()
        cameraStatus = await PermissionManager.camera.status
    }

    private func requestMicrophonePermission() async {
        let result = await PermissionManager.microphone.request()
        microphoneStatus = await PermissionManager.microphone.status
    }

    private func requestPhotoLibraryPermission() async {
        let result = await PermissionManager.photoLibrary.request()
        photoLibraryStatus = await PermissionManager.photoLibrary.status
    }

    private func requestAllPermissions() async {
        let result = await PermissionManager.request([
            .camera,
            .microphone,
            .photoLibrary
        ])
        await refreshPermissionStatuses()
    }

    private func refreshPermissionStatuses() async {
        cameraStatus = await PermissionManager.camera.status
        microphoneStatus = await PermissionManager.microphone.status
        photoLibraryStatus = await PermissionManager.photoLibrary.status
    }
}

struct PermissionRow: View {
    let title: String
    let status: PermissionStatus
    let requestAction: () async -> Void

    var body: some View {
        HStack {
            Text(title)
            Spacer()
            StatusBadge(status: status)

            if status != .authorized {
                Button("Request") {
                    Task {
                        await requestAction()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }
}

struct StatusBadge: View {
    let status: PermissionStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .cornerRadius(8)
    }

    private var statusText: String {
        switch status {
        case .notDetermined: return "Unknown"
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .limited: return "Limited"
        case .restricted: return "Restricted"
        }
    }

    private var statusColor: Color {
        switch status {
        case .notDetermined: return .gray
        case .authorized: return .green
        case .denied: return .red
        case .limited: return .orange
        case .restricted: return .purple
        }
    }
}

struct CodeExample: View {
    let title: String
    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)

            Text(code)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(.primary)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

#Preview {
    NavigationStack {
        PermissionDemoView()
    }
}
