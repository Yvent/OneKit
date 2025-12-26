//
//  GradientPlaygroundView.swift
//  OneKitDemo
//
//  Created by zyw on 2025/12/26.
//

import SwiftUI
import OneKitUI

struct GradientPlaygroundView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Linear Gradients
                Group {
                    GradientCard(title: "Vertical Gradient") {
                        Color.blue
                            .verticalGradientBackground(.blue, .purple)
                    }

                    GradientCard(title: "Horizontal Gradient") {
                        Color.green
                            .horizontalGradientBackground(.green, .blue)
                    }

                    GradientCard(title: "Diagonal Gradient") {
                        Color.orange
                            .diagonalGradientBackground(.orange, .pink)
                    }
                }

                // Radial Gradient
                Group {
                    GradientCard(title: "Radial Gradient") {
                        Color.yellow
                            .radialGradientBackground(.yellow, .red)
                    }
                }

                // Multi-stop Gradients
                Group {
                    GradientCard(title: "Multi-stop Vertical") {
                        Color.blue
                            .gradientBackground(stops: [
                                Gradient.Stop(color: .blue, location: 0.0),
                                Gradient.Stop(color: .purple, location: 0.5),
                                Gradient.Stop(color: .pink, location: 1.0)
                            ], startPoint: .top, endPoint: .bottom)
                    }

                    GradientCard(title: "Rainbow Gradient") {
                        Color.blue
                            .gradientBackground(stops: [
                                Gradient.Stop(color: .red, location: 0.0),
                                Gradient.Stop(color: .orange, location: 0.2),
                                Gradient.Stop(color: .yellow, location: 0.4),
                                Gradient.Stop(color: .green, location: 0.6),
                                Gradient.Stop(color: .blue, location: 0.8),
                                Gradient.Stop(color: .purple, location: 1.0)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gradient Playground")
    }
}

struct GradientCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            content
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    NavigationStack {
        GradientPlaygroundView()
    }
}
