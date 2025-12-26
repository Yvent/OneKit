//
//  AppInfoView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitCore

struct AppInfoView: View {
    var body: some View {
        List {
            Section("App Information") {
                InfoRow(label: "App Name", value: AppInfo.appName)
                InfoRow(label: "Version", value: AppInfo.appVersion)
                InfoRow(label: "Build", value: AppInfo.buildNumber)
            }

            Section("Links") {
                LinkRow(title: "App Store", url: AppInfo.appStoreURL, icon: "app.badge")
                LinkRow(title: "Rate & Review", url: AppInfo.appStoreReviewURL, icon: "star.fill")
            }
        }
        .navigationTitle("App Info")
    }
}

struct LinkRow: View {
    let title: String
    let url: URL?
    let icon: String

    var body: some View {
        if let url = url {
            Link(destination: url) {
                Label(title, systemImage: icon)
                    .foregroundStyle(.blue)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppInfoView()
    }
}
