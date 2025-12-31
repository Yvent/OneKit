//
//  ExifDemoView.swift
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

struct ExifDemoView: View {
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var exifMetadata: [String: Any]?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTab = 0

    var body: some View {
        Form {
            // Image Selection Section
            // 图片选择部分
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

                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Loading EXIF... / 正在加载 EXIF...")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                }

                if let error = errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            // Metadata Tabs
            // 元数据标签页
            if imageData != nil {
                Section {
                    Picker("View / 视图", selection: $selectedTab) {
                        Text("Raw Metadata / 原始元数据").tag(0)
                        Text("EXIF Dictionary / EXIF字典").tag(1)
                        Text("GPS Info / GPS信息").tag(2)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Display Options / 显示选项")
                }
            }

            // Display content based on selected tab
            // 根据选择的标签显示内容
            switch selectedTab {
            case 0:
                if let metadata = exifMetadata {
                    rawMetadataSection(metadata)
                }
            case 1:
                if let metadata = exifMetadata {
                    exifDictionarySection(metadata)
                }
            case 2:
                if let metadata = exifMetadata {
                    gpsInfoSection(metadata)
                }
            default:
                EmptyView()
            }
        }
        .navigationTitle("EXIF Reader")
    }

    // MARK: - Raw Metadata Section

    @ViewBuilder
    private func rawMetadataSection(_ metadata: [String: Any]) -> some View {
        Section("Raw Metadata / 原始元数据") {
            if metadata.isEmpty {
                Text("No metadata available / 无可用元数据")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(metadata.keys.sorted(), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(key)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatValue(metadata[key]))
                            .font(.system(.body, design: .monospaced))
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    // MARK: - EXIF Dictionary Section

    @ViewBuilder
    private func exifDictionarySection(_ metadata: [String: Any]) -> some View {
        Section("EXIF Dictionary / EXIF字典") {
            if let exifDict = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any] {
                if exifDict.isEmpty {
                    Text("No EXIF data available / 无 EXIF 数据")
                        .foregroundStyle(.secondary)
                } else {
                    // Camera Settings
                    // 相机设置
                    if let dateTime = exifDict[kCGImagePropertyExifDateTimeOriginal as String] as? String {
                        infoRow("Date/Time", dateTime)
                    }

                    if let make = exifDict[kCGImagePropertyExifLensMake as String] as? String {
                        infoRow("Lens Make", make)
                    }

                    if let lensModel = exifDict[kCGImagePropertyExifLensModel as String] as? String {
                        infoRow("Lens Model", lensModel)
                    }

                    Divider()

                    if let fNumber = exifDict[kCGImagePropertyExifFNumber as String] as? Double {
                        infoRow("Aperture", "f/\(fNumber)")
                    }

                    if let exposureTime = exifDict[kCGImagePropertyExifExposureTime as String] as? Double {
                        infoRow("Exposure", "\(exposureTime)s")
                    }

                    if let iso = exifDict[kCGImagePropertyExifISOSpeedRatings as String] as? [Int], let isoValue = iso.first {
                        infoRow("ISO", "ISO \(isoValue)")
                    }

                    if let focalLength = exifDict[kCGImagePropertyExifFocalLength as String] as? Float {
                        infoRow("Focal Length", "\(focalLength)mm")
                    }

                    if let flash = exifDict[kCGImagePropertyExifFlash as String] as? Int {
                        infoRow("Flash", flash == 1 ? "Yes / 是" : "No / 否")
                    }

                    Divider()

                    // All EXIF keys
                    // 所有 EXIF 键
                    ForEach(exifDict.keys.sorted(), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatValue(exifDict[key]))
                                .font(.system(.body, design: .monospaced))
                        }
                        .padding(.vertical, 2)
                    }
                }
            } else {
                Text("No EXIF dictionary found / 未找到 EXIF 字典")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - GPS Info Section

    @ViewBuilder
    private func gpsInfoSection(_ metadata: [String: Any]) -> some View {
        Section("GPS Info / GPS信息") {
            if let gpsDict = metadata[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
                if gpsDict.isEmpty || (gpsDict[kCGImagePropertyGPSLatitude as String] == nil) {
                    Text("No GPS data available / 无 GPS 数据")
                        .foregroundStyle(.secondary)
                } else {
                    // Key GPS fields
                    // 关键 GPS 字段
                    if let latitude = gpsDict[kCGImagePropertyGPSLatitude as String] as? Double {
                        infoRow("Latitude / 纬度", "\(latitude)")
                    }

                    if let longitude = gpsDict[kCGImagePropertyGPSLongitude as String] as? Double {
                        infoRow("Longitude / 经度", "\(longitude)")
                    }

                    if let altitude = gpsDict[kCGImagePropertyGPSAltitude as String] as? Double {
                        infoRow("Altitude / 海拔", "\(altitude)m")
                    }

                    if let latitudeRef = gpsDict[kCGImagePropertyGPSLatitudeRef as String] as? String {
                        infoRow("Latitude Ref / 纬度方向", latitudeRef)
                    }

                    if let longitudeRef = gpsDict[kCGImagePropertyGPSLongitudeRef as String] as? String {
                        infoRow("Longitude Ref / 经度方向", longitudeRef)
                    }

                    Divider()

                    // All GPS keys
                    // 所有 GPS 键
                    ForEach(gpsDict.keys.sorted(), id: \.self) { key in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(key)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(formatValue(gpsDict[key]))
                                .font(.system(.body, design: .monospaced))
                        }
                        .padding(.vertical, 2)
                    }
                }
            } else {
                Text("No GPS dictionary found / 未找到 GPS 字典")
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helper Views

    private func infoRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }

    private func formatValue(_ value: Any?) -> String {
        guard let value = value else {
            return "nil"
        }

        if let dict = value as? [String: Any] {
            return "{\(dict.keys.count) items}"
        } else if let array = value as? [Any] {
            return "[\(array.count) items]"
        } else {
            return "\(value)"
        }
    }

    // MARK: - Image Loading

    private func loadImage(from item: PhotosPickerItem?) {
        guard let item = item else {
            imageData = nil
            exifMetadata = nil
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                // Load image data
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        imageData = data

                        // Load full EXIF metadata (async)
                        Task {
                            do {
                                let metadata = try await data.fetchFullExif()
                                await MainActor.run {
                                    exifMetadata = metadata
                                    isLoading = false
                                }
                            } catch {
                                await MainActor.run {
                                    errorMessage = "Failed to load EXIF: \(error.localizedDescription)"
                                    isLoading = false
                                }
                            }
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load image: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ExifDemoView()
    }
}
