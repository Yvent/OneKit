//
//  DateExtensionsView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitCore

struct DateExtensionsView: View {
    @State private var selectedDate = Date()

    var body: some View {
        Form {
            Section("Current Time (Static)") {
                InfoRow(label: "GMT String", value: Date.gmtString)
                InfoRow(label: "ISO8601 String", value: Date.iso8601String)
                InfoRow(label: "Date String", value: Date.dateString)
                InfoRow(label: "Year/Month", value: Date.yearMonthString)
                InfoRow(label: "Month/Day", value: Date.monthDayString)
            }

            Section("Selected Date Formats") {
                DatePicker("Select Date", selection: $selectedDate)

                InfoRow(label: "ISO8601", value: selectedDate.iso8601String)
                InfoRow(label: "Date String", value: selectedDate.dateString)
                InfoRow(label: "Year/Month", value: selectedDate.yearMonthString)
                InfoRow(label: "Localized", value: selectedDate.localizedString)
            }

            Section("Date Conversion") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Format Parsing:")
                        .font(.headline)

                    if let parsed = Date.from(string: "2025/12/25", format: "yyyy/MM/dd") {
                        Text("Input: 2025/12/25")
                            .foregroundStyle(.secondary)
                        Text("Output: \(parsed.localizedString)")
                            .foregroundStyle(.blue)
                    }

                    if let parsed = Date.from(iso8601String: "2025-12-25T12:00:00") {
                        Text("ISO8601 Input: 2025-12-25T12:00:00")
                            .foregroundStyle(.secondary)
                        Text("Output: \(parsed.localizedString)")
                            .foregroundStyle(.blue)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Date Extensions")
    }
}

#Preview {
    NavigationStack {
        DateExtensionsView()
    }
}
