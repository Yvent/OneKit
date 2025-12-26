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

    var body: some View {
        List {
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
        }
        .navigationTitle("Permissions")
        .onAppear {
            Task {
                await refreshPermissionStatuses()
            }
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

#Preview {
    NavigationStack {
        PermissionDemoView()
    }
}
