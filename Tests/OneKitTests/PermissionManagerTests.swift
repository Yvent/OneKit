//
//  PermissionManagerTests.swift
//  OneKitTests
//
//  Created by OneKit
//

import Testing
@testable import OneKitCore
#if canImport(UIKit)
import UIKit
#endif

@Suite("Permission Manager Tests")
struct PermissionManagerTests {

    // MARK: - Permission Status Tests

    @Test("Camera permission status should be accessible")
    @MainActor
    func cameraPermissionStatus() async throws {
        let status = await PermissionManager.camera.status
        // Should return a valid status
        // 应该返回有效的状态
        #expect([.notDetermined, .authorized, .denied, .restricted].contains(status))
    }

    @Test("Microphone permission status should be accessible")
    @MainActor
    func microphonePermissionStatus() async throws {
        let status = await PermissionManager.microphone.status
        #expect([.notDetermined, .authorized, .denied, .restricted].contains(status))
    }

    @Test("Photo library permission status should be accessible")
    @MainActor
    func photoLibraryPermissionStatus() async throws {
        let status = await PermissionManager.photoLibrary.status
        #expect([.notDetermined, .authorized, .denied, .restricted, .limited].contains(status))
    }

    @Test("Location permission status should be accessible")
    @MainActor
    func locationPermissionStatus() async throws {
        let status = await PermissionManager.location.status
        #expect([.notDetermined, .authorized, .denied, .restricted].contains(status))
    }

    // MARK: - Permission Handle Tests

    @Test("Permission handle should have correct type")
    func permissionHandleType() {
        let cameraHandle = PermissionManager.camera
        #expect(cameraHandle.type == .camera)

        let microphoneHandle = PermissionManager.microphone
        #expect(microphoneHandle.type == .microphone)

        let photoLibraryHandle = PermissionManager.photoLibrary
        #expect(photoLibraryHandle.type == .photoLibrary)

        let locationHandle = PermissionManager.location
        #expect(locationHandle.type == .location)
    }

    // MARK: - Batch Permission Tests

    @Test("Should check status of multiple permissions")
    @MainActor
    func batchStatusCheck() async throws {
        let statuses = await PermissionManager.checkStatus([
            .camera, .microphone, .photoLibrary, .location
        ])

        #expect(statuses.count == 4)
        #expect(statuses.keys.contains(.camera))
        #expect(statuses.keys.contains(.microphone))
        #expect(statuses.keys.contains(.photoLibrary))
        #expect(statuses.keys.contains(.location))

        for (_, status) in statuses {
            #expect([.notDetermined, .authorized, .denied, .restricted, .limited].contains(status))
        }
    }

    @Test("Batch status check with empty array should return empty result")
    @MainActor
    func batchStatusCheckEmpty() async throws {
        let statuses = await PermissionManager.checkStatus([])
        #expect(statuses.isEmpty)
    }

    @Test("Batch status check with single permission")
    @MainActor
    func batchStatusCheckSingle() async throws {
        let statuses = await PermissionManager.checkStatus([.camera])
        #expect(statuses.count == 1)
        #expect(statuses.keys.contains(.camera))
    }

    // MARK: - Edge Cases Tests

    @Test("Should handle permission status stability")
    @MainActor
    func statusStability() async throws {
        let status1 = await PermissionManager.camera.status
        let status2 = await PermissionManager.camera.status
        #expect(status1 == status2)
    }

    @Test("PermissionType should be hashable")
    func permissionTypeHashable() {
        let set: Set<PermissionType> = [.camera, .microphone, .photoLibrary, .location]
        #expect(set.count == 4)
    }

    @Test("PermissionResult should be equatable")
    func permissionResultEquatable() {
        #expect(PermissionResult.granted == .granted)
        #expect(PermissionResult.denied == .denied)
        #expect(PermissionResult.restricted == .restricted)
        #expect(PermissionResult.granted != .denied)
    }

    @Test("BatchPermissionResult with all granted should have allGranted true")
    func batchResultAllGranted() {
        let results: [PermissionType: PermissionResult] = [
            .camera: .granted,
            .microphone: .granted
        ]
        let batchResult = BatchPermissionResult(results: results)
        #expect(batchResult.allGranted == true)
    }

    @Test("BatchPermissionResult with denied should have allGranted false")
    func batchResultWithDenied() {
        let results: [PermissionType: PermissionResult] = [
            .camera: .granted,
            .microphone: .denied
        ]
        let batchResult = BatchPermissionResult(results: results)
        #expect(batchResult.allGranted == false)
    }

    @Test("BatchPermissionResult should contain all results")
    func batchResultContents() {
        let results: [PermissionType: PermissionResult] = [
            .camera: .granted,
            .microphone: .denied,
            .photoLibrary: .granted
        ]
        let batchResult = BatchPermissionResult(results: results)
        #expect(batchResult.results.count == 3)
        #expect(batchResult.results[.camera] == .granted)
        #expect(batchResult.results[.microphone] == .denied)
        #expect(batchResult.results[.photoLibrary] == .granted)
    }

    @Test("PermissionStatus should be equatable")
    func permissionStatusEquatable() {
        #expect(PermissionStatus.authorized == .authorized)
        #expect(PermissionStatus.denied == .denied)
        #expect(PermissionStatus.notDetermined == .notDetermined)
        #expect(PermissionStatus.authorized != .denied)
    }

    // MARK: - Can Request Tests

    @Test("Can request should return boolean")
    @MainActor
    func canRequestReturnsBool() async throws {
        let canRequest = await PermissionManager.camera.canRequest
        // Should be true or false, not crash
        // 应该返回 true 或 false，不会崩溃
        _ = canRequest
    }
}
