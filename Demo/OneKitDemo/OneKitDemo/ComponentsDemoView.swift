//
//  ComponentsDemoView.swift
//  OneKitDemo
//
//  Created by OneKit
//

import SwiftUI
import OneKitCore

struct ComponentsDemoView: View {
    @State private var selectedTab = 0
    @State private var isLoading = false
    @State private var progress: Double = 0.0
    @State private var showEmptyStates = false

    var body: some View {
        TabView(selection: $selectedTab) {
            EmptyStateExamples()
                .tabItem {
                    Label("Empty State", systemImage: "tray")
                }
                .tag(0)

            LoadingExamples()
                .tabItem {
                    Label("Loading", systemImage: "progress.indicator")
                }
                .tag(1)
        }
        .navigationTitle("UI Components")
    }
}

// MARK: - Empty State Examples

struct EmptyStateExamples: View {
    @State private var showNoData = true
    @State private var showNoResults = false
    @State private var showNoFavorites = false

    var body: some View {
        List {
            Section {
                Text("Different styles of empty states")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Examples") {
                // Toggle examples
                Button("Show No Data Example") {
                    showNoData.toggle()
                }
                Button("Show No Results Example") {
                    showNoResults.toggle()
                }
                Button("Show No Favorites Example") {
                    showNoFavorites.toggle()
                }
            }

            Section("Preview") {
                if showNoData {
                    EmptyStateView(
                        icon: "tray",
                        title: "No Data",
                        message: "Get started by adding your first item",
                        actionTitle: "Add Item",
                        action: {
                            showNoData = false
                        }
                    )
                    .transition(.opacity)
                }

                if showNoResults {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results Found",
                        message: "We couldn't find anything matching your search"
                    )
                    .transition(.opacity)
                }

                if showNoFavorites {
                    EmptyStateView.compact(
                        icon: "heart",
                        title: "No Favorites Yet",
                        message: "Tap the heart icon on any item to save it here"
                    )
                    .transition(.opacity)
                }
            }
        }
    }
}

// MARK: - Loading Examples

struct LoadingExamples: View {
    @State private var isSmallLoading = false
    @State private var isMediumLoading = false
    @State private var isLargeLoading = false
    @State private var showProgress = false
    @State private var progress: Double = 0.0
    @State private var showSkeleton = false

    var body: some View {
        List {
            Section {
                Text("Different loading styles and animations")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Spinners") {
                Toggle("Small Loading", isOn: $isSmallLoading)
                Toggle("Medium Loading", isOn: $isMediumLoading)
                Toggle("Large Loading", isOn: $isLargeLoading)
            }

            Section("Progress") {
                Toggle("Show Progress", isOn: $showProgress)

                if showProgress {
                    VStack(alignment: .leading, spacing: 12) {
                        LoadingView(progress: progress, message: "Downloading...")

                        Slider(value: $progress, in: 0...1) {
                            Text("Progress")
                        }

                        Button("Reset") {
                            withAnimation {
                                progress = 0
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.vertical, 8)
                }
            }

            Section("Skeleton") {
                Toggle("Show Skeleton", isOn: $showSkeleton)

                if showSkeleton {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Skeleton Examples")
                            .font(.headline)

                        Text("Single line skeleton:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LoadingView.skeleton(height: 60)
                            .frame(maxWidth: .infinity)

                        Text("Multiple lines skeleton:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        LoadingView.skeleton(lines: 3)
                    }
                    .padding(.vertical, 8)
                }
            }

            Section("Overlay Example") {
                Button("Show Overlay Loading") {
                    isMediumLoading = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isMediumLoading = false
                    }
                }
                .buttonStyle(.bordered)

                Color.clear
                    .frame(height: 100)
                    .loading(isMediumLoading, message: "Loading data...")
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.quaternary, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ComponentsDemoView()
    }
}
