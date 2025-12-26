//
//  HapticDemoView.swift
//  OneKitDemo
//
//  Created by OneKit
//

import SwiftUI
import OneKitUI

struct HapticDemoView: View {
    @State private var counter = 0
    @State private var toggleOn = false

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Reactive Mode")
                        .font(.headline)
                    Text("Haptic triggers automatically when the value changes")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                // Counter with haptic feedback
                HStack {
                    Button("-") {
                        counter -= 1
                    }
                    .buttonStyle(.bordered)
                    .disabled(counter <= 0)

                    Text("\(counter)")
                        .font(.title)
                        .frame(maxWidth: .infinity)

                    Button("+") {
                        counter += 1
                    }
                    .buttonStyle(.bordered)
                }
                .haptic(.decrease, trigger: counter)
            } header: {
                Text("Counter with Haptic")
            } footer: {
                Text("Each increment/decrease triggers haptic feedback")
            }

            Section {
                Toggle("Toggle with Haptic", isOn: $toggleOn)
                    .haptic(toggleOn ? .success : .warning, trigger: toggleOn)
            } header: {
                Text("Toggle Feedback")
            } footer: {
                Text("Different feedback for on/off states")
            }

            Section {
                ForEach(HapticType.allCases) { type in
                    Button(type.displayName) {
                        type.feedback.trigger()
                    }
                }
            } header: {
                Text("Manual Trigger")
            } footer: {
                Text("Tap to trigger haptic feedback manually")
            }

            Section {
                VStack(alignment: .leading, spacing: 12) {
                    CodeExample(
                        title: "With Trigger (Reactive)",
                        code: """
                        @State private var count = 0

                        Button("Increment") {
                            count += 1
                        }
                        .haptic(.increase, trigger: count)
                        """
                    )

                    CodeExample(
                        title: "Without Trigger (Manual)",
                        code: """
                        Button("Tap Me") {
                            // Action
                        }
                        .haptic(.impact(.light))
                        """
                    )

                    CodeExample(
                        title: "Impact Intensity",
                        code: """
                        .haptic(.impact(.light))
                        .haptic(.impact(.medium))
                        .haptic(.impact(.heavy))
                        """
                    )
                }
            } header: {
                Text("Code Examples")
            }
        }
        .navigationTitle("Haptic Feedback")
    }
}

struct HapticType: Identifiable, CaseIterable {
    let id: UUID = UUID()
    let displayName: String
    let feedback: HapticFeedback

    static let allCases: [HapticType] = [
        HapticType(displayName: "Selection", feedback: .selection),
        HapticType(displayName: "Light Impact", feedback: .impact(.light)),
        HapticType(displayName: "Medium Impact", feedback: .impact(.medium)),
        HapticType(displayName: "Heavy Impact", feedback: .impact(.heavy)),
        HapticType(displayName: "Success", feedback: .success),
        HapticType(displayName: "Warning", feedback: .warning),
        HapticType(displayName: "Error", feedback: .error),
        HapticType(displayName: "Increase", feedback: .increase),
        HapticType(displayName: "Decrease", feedback: .decrease),
        HapticType(displayName: "Start", feedback: .start),
        HapticType(displayName: "Stop", feedback: .stop),
    ]
}

#Preview {
    NavigationStack {
        HapticDemoView()
    }
}
