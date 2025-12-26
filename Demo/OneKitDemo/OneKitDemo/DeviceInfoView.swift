//
//  DeviceInfoView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitCore

struct DeviceInfoView: View {
    var body: some View {
        List {
            // System Information
            Section("System") {
                InfoRow(label: "Device Model", value: DeviceInfo.deviceModel)
                InfoRow(label: "Device Name", value: DeviceInfo.deviceModelName)
                InfoRow(label: "System Version", value: DeviceInfo.systemVersion)
                InfoRow(label: "Language", value: DeviceInfo.currentLanguage)
                InfoRow(label: "Language Code", value: DeviceInfo.currentLanguageCode)
                InfoRow(label: "Uptime", value: DeviceSystem.uptimeString)
            }

            // Hardware Information
            Section("Hardware") {
                InfoRow(label: "CPU Count", value: "\(DeviceHardware.cpuCount)")
                InfoRow(label: "CPU Type", value: DeviceHardware.cpuType)
                InfoRow(label: "Extended Model", value: DeviceHardware.extendedDeviceModelName)
            }

            // Storage Information
            Section("Storage") {
                InfoRow(label: "Total Capacity", value: DeviceStorage.totalCapacity)
                InfoRow(label: "Available Capacity", value: DeviceStorage.availableCapacity)
                InfoRow(label: "Used Capacity", value: DeviceStorage.usedCapacity)
                InfoRow(label: "Usage", value: String(format: "%.1f%%", DeviceStorage.usagePercentage))
            }

            // Network Information
            Section("Network") {
                InfoRow(label: "Carrier Name", value: DeviceNetwork.carrierName)
                InfoRow(label: "Carrier Code", value: DeviceNetwork.carrierCode)
                InfoRow(label: "IP Address", value: DeviceNetwork.ipAddress)
            }
        }
        .navigationTitle("Device Info")
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        DeviceInfoView()
    }
}
