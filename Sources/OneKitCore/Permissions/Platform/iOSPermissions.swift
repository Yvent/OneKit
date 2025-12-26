//
//  iOSPermissions.swift
//  OneKit
//
//  Created by OneKit
//

#if os(iOS)
import Foundation
import AVFoundation
import Photos
import CoreLocation
import UIKit

/// iOS-specific permission handler
///
/// iOS 权限处理器
@MainActor
enum iOSPermissionHandler {

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
        case .restricted: return .restricted
        case .limited: return .limited
        @unknown default: return .denied
        }
    }

    private static func locationStatus() -> PermissionStatus {
        // Note: CLLocationManager requires instance-based authorization
        // Return notDetermined as default for static API
        // Applications should create CLLocationManager for actual location use
        return .notDetermined
    }

    // MARK: - Request Permissions

    static func request(_ type: PermissionType) async -> PermissionResult {
        // Check if permission was previously denied
        let previousStatus = status(for: type)

        // If previously denied and autoShowSettingsAlert is enabled, show alert first
        if previousStatus == .denied && PermissionManager.autoShowSettingsAlert {
            // Check if custom handler is provided
            if let handler = PermissionManager.permissionDeniedHandler {
                let handled = handler(type)
                if !handled {
                    // Handler returned false, show default alert
                    await showSettingsAlert(for: type)
                }
                // If handled is true, handler already showed custom alert, do nothing
            } else {
                // No custom handler, show default alert
                await showSettingsAlert(for: type)
            }
            return .denied
        }

        // Request permission normally
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
        // Note: CLLocationManager requires instance-based authorization
        // This is a simplified implementation
        // Applications should use CLLocationManager directly for location
        return .denied
    }

    // MARK: - Settings Alert

    /// Show alert prompting user to go to Settings
    ///
    /// 显示引导用户前往设置的弹窗
    private static func showSettingsAlert(for type: PermissionType) {
        // Check if custom configuration is provided
        if let customConfig = PermissionManager.customAlertConfiguration,
           let config = customConfig[type] {
            // Use custom configuration (all text is customized)
            let alert = UIAlertController(
                title: config.title,
                message: config.message,
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: config.cancelButton,
                style: .cancel
            ))

            alert.addAction(UIAlertAction(
                title: config.openSettingsButton,
                style: .default
            ) { _ in
                try? openSettings()
            })

            presentAlert(alert)
        } else {
            // Use default configuration
            let alert = UIAlertController(
                title: defaultAlertTitle(for: type),
                message: defaultAlertMessage(for: type),
                preferredStyle: .alert
            )

            alert.addAction(UIAlertAction(
                title: "Cancel",
                style: .cancel
            ))

            alert.addAction(UIAlertAction(
                title: "Open Settings",
                style: .default
            ) { _ in
                try? openSettings()
            })

            presentAlert(alert)
        }
    }

    private static func presentAlert(_ alert: UIAlertController) {
        // Present alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        } else if let window = UIApplication.shared.windows.first,
                  let rootViewController = window.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }

    private static func defaultAlertTitle(for type: PermissionType) -> String {
        switch type {
        case .camera:
            return "Camera Access Denied"
        case .microphone:
            return "Microphone Access Denied"
        case .photoLibrary:
            return "Photo Library Access Denied"
        case .location:
            return "Location Access Denied"
        }
    }

    private static func defaultAlertMessage(for type: PermissionType) -> String {
        switch type {
        case .camera:
            return "Please enable camera access in Settings to use this feature."
        case .microphone:
            return "Please enable microphone access in Settings to use this feature."
        case .photoLibrary:
            return "Please enable photo library access in Settings to use this feature."
        case .location:
            return "Please enable location access in Settings to use this feature."
        }
    }

    // MARK: - Open Settings

    static func openSettings() throws {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            throw PermissionError.settingsURLUnavailable
        }
        UIApplication.shared.open(settingsURL)
    }

    // MARK: - Can Request

    static func canRequest(_ type: PermissionType) -> Bool {
        // Check if permission can be requested in current context
        // For example, cannot request in App Extensions
        guard !isAppExtension else {
            return false
        }

        let status = self.status(for: type)
        return status == .notDetermined
    }

    // MARK: - Helpers

    private static var isAppExtension: Bool {
        // Check if running in App Extension
        return Bundle.main.bundlePath.hasSuffix(".appex")
    }
}
#endif
