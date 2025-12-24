//
//  macOSPermissions.swift
//  OneKit
//
//  Created by OneKit
//

#if os(macOS)
import Foundation
import AVFoundation
import Photos
import AppKit

/// macOS-specific permission handler
///
/// macOS 权限处理器
@MainActor
enum macOSPermissionHandler {

    // MARK: - Status Check

    static func status(for type: PermissionType) -> PermissionStatus {
        switch type {
        case .camera:
            return cameraStatus()
        case .microphone:
            return microphoneStatus()
        case .photoLibrary:
            return photoLibraryStatus()
        case .location:
            return locationStatus()
        }
    }

    private static func cameraStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    private static func microphoneStatus() -> PermissionStatus {
        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    private static func photoLibraryStatus() -> PermissionStatus {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined: return .notDetermined
        case .authorized: return .authorized
        case .denied: return .denied
        case .limited: return .limited
        case .restricted: return .restricted
        @unknown default: return .denied
        }
    }

    private static func locationStatus() -> PermissionStatus {
        // Location on macOS requires different approach
        // Return notDetermined as default
        return .notDetermined
    }

    // MARK: - Request Permissions

    static func request(_ type: PermissionType) async -> PermissionResult {
        switch type {
        case .camera:
            return await requestCamera()
        case .microphone:
            return await requestMicrophone()
        case .photoLibrary:
            return await requestPhotoLibrary()
        case .location:
            return await requestLocation()
        }
    }

    private static func requestCamera() async -> PermissionResult {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }

    private static func requestMicrophone() async -> PermissionResult {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }

    private static func requestPhotoLibrary() async -> PermissionResult {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        switch status {
        case .authorized, .limited: return .granted
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .denied
        @unknown default: return .denied
        }
    }

    private static func requestLocation() async -> PermissionResult {
        // Location on macOS requires different approach
        return .denied
    }

    // MARK: - Open Settings

    static func openSettings() throws {
        // macOS uses different approach for opening settings
        // Open System Preferences > Security & Privacy
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security") {
            NSWorkspace.shared.open(url)
        } else {
            throw PermissionError.settingsURLUnavailable
        }
    }

    // MARK: - Can Request

    static func canRequest(_ type: PermissionType) -> Bool {
        let status = self.status(for: type)
        return status == .notDetermined
    }
}
#endif
