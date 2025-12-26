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
            VStack(spacing: 30) {
                // Basic Linear Gradients
                Section("Linear Gradients") {
                    GradientDemoCard(title: "Vertical (Top → Bottom)") {
                        Text("Vertical Gradient")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .verticalGradientBackground(.blue, .purple)
                    }

                    GradientDemoCard(title: "Horizontal (Left → Right)") {
                        Text("Horizontal Gradient")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .horizontalGradientBackground(.green, .blue)
                    }

                    GradientDemoCard(title: "Diagonal (TopLeft → BottomRight)") {
                        Text("Diagonal Gradient")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .diagonalGradientBackground(.orange, .pink)
                    }
                }

                // Radial Gradient
                Section("Radial Gradient") {
                    GradientDemoCard(title: "Radial (Center → Out)") {
                        Text("Radial Gradient")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .radialGradientBackground(.yellow, .red)
                    }
                }

                // Angular Gradient
                Section("Angular Gradient") {
                    GradientDemoCard(title: "Angular (Conic)") {
                        Text("Angular")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .angularGradientBackground(.cyan, .blue)
                    }
                }

                // Multi-stop Gradients
                Section("Multi-stop Gradients") {
                    GradientDemoCard(title: "Three-Color Vertical") {
                        Text("3 Colors")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gradientBackground(stops: [
                                Gradient.Stop(color: .blue, location: 0.0),
                                Gradient.Stop(color: .purple, location: 0.5),
                                Gradient.Stop(color: .pink, location: 1.0)
                            ], startPoint: .top, endPoint: .bottom)
                    }

                    GradientDemoCard(title: "Rainbow (Diagonal)") {
                        Text("🌈 Rainbow")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gradientBackground(stops: [
                                Gradient.Stop(color: .red, location: 0.0),
                                Gradient.Stop(color: .orange, location: 0.2),
                                Gradient.Stop(color: .yellow, location: 0.4),
                                Gradient.Stop(color: .green, location: 0.6),
                                Gradient.Stop(color: .blue, location: 0.8),
                                Gradient.Stop(color: .purple, location: 1.0)
                            ], startPoint: .topLeading, endPoint: .bottomTrailing)
                    }

                    GradientDemoCard(title: "Ocean Depths") {
                        Text("Ocean")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .gradientBackground(stops: [
                                Gradient.Stop(color: .cyan.opacity(0.3), location: 0.0),
                                Gradient.Stop(color: .cyan, location: 0.3),
                                Gradient.Stop(color: .blue, location: 0.7),
                                Gradient.Stop(color: .blue.opacity(0.8), location: 1.0)
                            ], startPoint: .top, endPoint: .bottom)
                    }
                }

                // Direction Presets
                Section("Direction Variants") {
                    GradientDemoCard(title: "Top to Bottom") {
                        Text("↓")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .gradientBackground(.indigo, .purple, direction: .topToBottom)
                    }

                    GradientDemoCard(title: "Bottom to Top") {
                        Text("↑")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .gradientBackground(.indigo, .purple, direction: .bottomToTop)
                    }

                    GradientDemoCard(title: "Left to Right") {
                        Text("→")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .gradientBackground(.indigo, .purple, direction: .leftToRight)
                    }

                    GradientDemoCard(title: "Right to Left") {
                        Text("←")
                            .font(.system(size: 48))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .gradientBackground(.indigo, .purple, direction: .rightToLeft)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Gradient Playground")
    }
}

struct GradientDemoCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)

            content
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
                .shadow(radius: 8, y: 4)
        }
    }
}

#Preview {
    NavigationStack {
        GradientPlaygroundView()
    }
}
