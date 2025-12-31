//
//  ImageSaverDemoView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/31.
//

import SwiftUI
import PhotosUI
import OneKitCore

#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit)

struct ImageSaverDemoView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var uiImage: UIImage?
    @State private var albumName = ""
    @State private var saveStatus: SaveStatus = .idle
    @State private var savedAssetIdentifier: String?
    @State private var showPermissionAlert = false
    @State private var authorizationStatus: PHAuthorizationStatus = .notDetermined

    private let imageSaver = ImageSaver()

    enum SaveStatus {
        case idle
        case saving
        case success(String)
        case failure(String)
    }

    var body: some View {
        Form {
            // Image Selection Section
            Section("Image Selection / 图片选择") {
                PhotosPicker(
                    selection: $selectedImage,
                    matching: .images
                ) {
                    Label("Pick Image / 选择图片", systemImage: "photo")
                }
                .onChange(of: selectedImage) { oldValue, newValue in
                    loadImage(from: newValue)
                }

                if let uiImage = uiImage {
                    HStack {
                        Spacer()
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        Spacer()
                    }
                    .padding()
                }
            }

            // Album Name Section
            Section("Album Settings / 相册设置") {
                TextField("Album Name (Optional) / 相册名称（可选）", text: $albumName)
                    .textFieldStyle(.roundedBorder)

                Text("Leave empty to save to Camera Roll / 留空则保存到相机胶卷")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Authorization Status
            Section("Authorization / 权限状态") {
                HStack {
                    Text("Status / 状态")
                    Spacer()
                    authorizationStatusView
                }

                Button("Check Authorization / 检查权限") {
                    Task {
                        await updateAuthorizationStatus()
                    }
                }

                Button("Request Authorization / 请求权限") {
                    Task {
                        await requestPermission()
                    }
                }
            }

            // Save Action
            Section {
                Button(action: saveImage) {
                    HStack {
                        Spacer()
                        if case .saving = saveStatus {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Saving... / 正在保存...")
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Save to Photo Library / 保存到相册")
                        }
                        Spacer()
                    }
                }
                .disabled(uiImage == nil || saveStatus == .saving)
            }

            // Save Result
            Section("Save Result / 保存结果") {
                switch saveStatus {
                case .idle:
                    Text("Select an image and save / 选择图片后保存")
                        .foregroundStyle(.secondary)

                case .saving:
                    EmptyView()

                case .success(let message):
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(message)
                        Spacer()
                    }

                case .failure(let error):
                    HStack {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.red)
                        Text(error)
                            .font(.caption)
                        Spacer()
                    }
                }

                if let identifier = savedAssetIdentifier {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Asset ID:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(identifier)
                            .font(.system(.caption, design: .monospaced))
                            .lineLimit(2)
                    }
                }
            }
        }
        .navigationTitle("Image Saver / 图片保存")
        .alert("Permission Required", isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text("Please grant photo library access in Settings."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Authorization Status View

    @ViewBuilder
    private var authorizationStatusView: some View {
        switch authorizationStatus {
        case .authorized, .limited:
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text(authorizationStatus == .authorized ? "Authorized" : "Limited")
            }

        case .denied, .restricted:
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text("Denied / 限制")
            }

        case .notDetermined:
            HStack {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.orange)
                Text("Not Determined / 未确定")
            }

        @unknown default:
            Text("Unknown / 未知")
        }
    }

    // MARK: - Actions

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else {
            imageData = nil
            uiImage = nil
            saveStatus = .idle
            return
        }

        saveStatus = .idle

        Task {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        self.imageData = data
                        self.uiImage = UIImage(data: data)
                    }
                }
            } catch {
                await MainActor.run {
                    self.saveStatus = .failure(error.localizedDescription)
                }
            }
        }
    }

    private func updateAuthorizationStatus() async {
        authorizationStatus = await imageSaver.checkAuthorizationStatus()
    }

    private func requestPermission() async {
        authorizationStatus = await imageSaver.requestAuthorization()

        if authorizationStatus == .denied || authorizationStatus == .restricted {
            showPermissionAlert = true
        }
    }

    private func saveImage() {
        guard let image = uiImage else { return }

        saveStatus = .saving
        savedAssetIdentifier = nil

        Task {
            do {
                let asset = try await imageSaver.save(
                    image,
                    toAlbum: albumName.isEmpty ? nil : albumName
                )

                await MainActor.run {
                    saveStatus = .success("Saved successfully! / 保存成功")
                    savedAssetIdentifier = asset.localIdentifier
                }
            } catch let error as ImageSaverError {
                await MainActor.run {
                    saveStatus = .failure(error.localizedDescription)
                    if case .permissionDenied = error {
                        showPermissionAlert = true
                    }
                }
            } catch {
                await MainActor.run {
                    saveStatus = .failure(error.localizedDescription)
                }
            }
        }
    }
}

#endif

#if canImport(UIKit)

#Preview("Image Saver Demo") {
    NavigationStack {
        ImageSaverDemoView()
    }
}

#endif
