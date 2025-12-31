//
//  WebViewDemoView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/31.
//

import SwiftUI
import OneKitUI

#if canImport(UIKit)

struct WebViewDemoView: View {
    @State private var url = ""
    @State private var customTitle = ""
    @State private var selectedColor = Color.blue
    @State private var showWebView = false

    private let presetURLs: [(url: String, title: String)] = [
        ("https://www.apple.com", "Apple"),
        ("https://www.github.com", "GitHub"),
        ("https://www.baidu.com", "百度"),
        ("https://developer.apple.com", "Apple Developer")
    ]

    private let colorOptions: [(name: String, color: Color)] = [
        ("Blue / 蓝色", .blue),
        ("Red / 红色", .red),
        ("Green / 绿色", .green),
        ("Orange / 橙色", .orange),
        ("Purple / 紫色", .purple),
        ("Black / 黑色", .black),
        ("Primary / 主色", .primary)
    ]

    var body: some View {
        Form {
            Section("URL Input / URL 输入") {
                TextField("Enter URL / 输入网址", text: $url)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                TextField("Custom Title / 自定义标题（可选）", text: $customTitle)
                    .textFieldStyle(.roundedBorder)
            }

            Section {
                Button("Load URL / 加载网址") {
                    showWebView = true
                }
                .frame(maxWidth: .infinity)
                .disabled(url.isEmpty)
            }

            Section("Preset URLs / 预设网址") {
                ForEach(presetURLs, id: \.url) { preset in
                    Button(preset.title) {
                        url = preset.url
                        customTitle = preset.title
                        showWebView = true
                    }
                    .foregroundStyle(.blue)
                }
            }

            Section("Tint Color / 主题颜色") {
                Picker("Color / 颜色", selection: $selectedColor) {
                    ForEach(colorOptions, id: \.name) { option in
                        HStack {
                            Circle()
                                .fill(option.color)
                                .frame(width: 20, height: 20)
                            Text(option.name)
                        }
                        .tag(option.color)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("Preview / 预览") {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current URL:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(url.isEmpty ? "No URL" : url)
                            .font(.system(.body, design: .monospaced))
                            .lineLimit(2)
                    }
                    Spacer()
                    Image(systemName: "safari")
                        .font(.title2)
                        .foregroundStyle(selectedColor)
                }
            }
        }
        .navigationTitle("WebView Demo")
        .sheet(isPresented: $showWebView) {
            if !url.isEmpty {
                WebContentView(url: url, title: customTitle.isEmpty ? "网页" : customTitle, tintColor: selectedColor)
            }
        }
    }
}

#endif

#if canImport(UIKit)

#Preview {
    NavigationStack {
        WebViewDemoView()
    }
}

#endif
