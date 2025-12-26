//
//  StringExtensionsView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitCore

struct StringExtensionsView: View {
    @State private var dateString = "2025-12-25 15:30:00"
    @State private var searchText = "Hello World"

    var body: some View {
        Form {
            Section("Date Conversion") {
                TextField("Date String (yyyy-MM-dd HH:mm:ss)", text: $dateString)
                    .textFieldStyle(.roundedBorder)

                if let date = dateString.toDate() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Parsed Date:")
                            .font(.headline)
                        Text(date.localizedString)
                            .foregroundStyle(.secondary)

                        Divider()

                        Text("Timestamp (ms):")
                            .font(.headline)
                        Text("\(dateString.toTimestamp() ?? 0)")
                            .foregroundStyle(.blue)
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("String Search") {
                TextField("Search Text", text: $searchText)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Contains 'hello':")
                        Spacer()
                        Text(searchText.containsIgnoringCase("hello") ? "Yes" : "No")
                            .foregroundStyle(searchText.containsIgnoringCase("hello") ? .green : .red)
                    }

                    HStack {
                        Text("Contains 'world':")
                        Spacer()
                        Text(searchText.containsIgnoringCase("world") ? "Yes" : "No")
                            .foregroundStyle(searchText.containsIgnoringCase("world") ? .green : .red)
                    }

                    HStack {
                        Text("Contains 'test':")
                        Spacer()
                        Text(searchText.containsIgnoringCase("test") ? "Yes" : "No")
                            .foregroundStyle(searchText.containsIgnoringCase("test") ? .green : .red)
                    }
                }
            }

            #if canImport(UIKit)
            Section("String Measurement (iOS Only)") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("OneKit String Extensions")
                        .font(.system(size: 17))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))

                    VStack(alignment: .leading, spacing: 4) {
                        let size = "OneKit String Extensions".size(
                            for: UIFont.systemFont(ofSize: 17),
                            constrainedTo: CGSize(width: 300, height: 100)
                        )
                        Text("Width: \(Int(size.width))px")
                        Text("Height: \(Int(size.height))px")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            #endif
        }
        .navigationTitle("String Extensions")
    }
}

#Preview {
    NavigationStack {
        StringExtensionsView()
    }
}
