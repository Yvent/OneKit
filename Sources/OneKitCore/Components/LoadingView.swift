//
//  LoadingView.swift
//  OneKitCore
//
//  Created by OneKit
//

import SwiftUI

/// A view that displays loading indicators with various styles
///
/// 显示各种风格加载指示器的视图
///
/// **Basic Usage:**
/// ```swift
/// LoadingView()
/// LoadingView("Loading...")
/// LoadingView("Please wait", style: .large)
/// ```
///
/// **Progress:**
/// ```swift
/// LoadingView(progress: 0.7)
/// LoadingView(progress: downloadedRatio, message: "Downloading...")
/// ```
///
/// **Skeleton:**
/// ```swift
/// LoadingView.skeleton(height: 100)
/// LoadingView.skeleton(lines: 3)
/// ```
public struct LoadingView: View {

    // MARK: - Styles

    /// Loading style
    ///
    /// 加载样式
    public enum Style {
        /// Small inline spinner
        /// 小型内联加载器
        case small

        /// Medium spinner (default)
        /// 中型加载器（默认）
        case medium

        /// Large spinner
        /// 大型加载器
        case large

        /// Progress bar
        /// 进度条
        case progress

        /// Skeleton loading
        /// 骨架屏加载
        case skeleton
    }

    // MARK: - Properties

    /// The loading message
    ///
    /// 加载消息
    let message: String?

    /// The progress value (0.0 - 1.0)
    ///
    /// 进度值（0.0 - 1.0）
    let progress: Double?

    /// The loading style
    ///
    /// 加载样式
    let style: Style

    /// The skeleton height (for skeleton style)
    ///
    /// 骨架高度（用于骨架样式）
    let skeletonHeight: CGFloat?

    /// The number of skeleton lines
    ///
    /// 骨架行数
    let skeletonLines: Int?

    // MARK: - Initialization

    /// Create a loading view
    ///
    /// 创建加载视图
    ///
    /// - Parameters:
    ///   - message: The loading message / 加载消息（可选）
    ///   - progress: The progress value / 进度值（可选，0-1）
    ///   - style: The loading style / 加载样式（默认：.medium）
    public init(
        _ message: String? = nil,
        progress: Double? = nil,
        style: Style = .medium
    ) {
        self.message = message
        self.progress = progress
        self.style = progress != nil ? .progress : style
        self.skeletonHeight = nil
        self.skeletonLines = nil
    }

    /// Create a progress loading view
    ///
    /// 创建进度加载视图
    ///
    /// - Parameters:
    ///   - progress: The progress value (0.0 - 1.0) / 进度值
    ///   - message: The loading message / 加载消息（可选）
    public init(
        progress: Double,
        message: String? = nil
    ) {
        self.message = message
        self.progress = progress
        self.style = .progress
        self.skeletonHeight = nil
        self.skeletonLines = nil
    }

    /// Create a skeleton loading view
    ///
    /// 创建骨架屏加载视图
    ///
    /// - Parameters:
    ///   - height: The skeleton height / 骨架高度
    ///   - lines: The number of lines / 行数（默认：1）
    private init(
        skeletonHeight: CGFloat?,
        lines: Int? = nil
    ) {
        self.message = nil
        self.progress = nil
        self.style = .skeleton
        self.skeletonHeight = skeletonHeight
        self.skeletonLines = lines
    }

    // MARK: - Body

    public var body: some View {
        Group {
            switch style {
            case .small, .medium, .large:
                spinnerView
            case .progress:
                progressView
            case .skeleton:
                skeletonView
            }
        }
    }

    // MARK: - Spinner View

    private var spinnerView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(spinnerScale)
                .controlSize(controlSize)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
    }

    private var spinnerScale: CGFloat {
        switch style {
        case .small: return 0.8
        case .medium: return 1.0
        case .large: return 1.2
        default: return 1.0
        }
    }

    private var controlSize: ControlSize {
        switch style {
        case .small: return .small
        case .medium: return .regular
        case .large: return .large
        default: return .regular
        }
    }

    // MARK: - Progress View

    private var progressView: some View {
        VStack(spacing: 12) {
            if let progress = progress {
                ProgressView(value: progress, total: 1.0)
                    .progressViewStyle(.linear)

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
            }
        }
        .padding(20)
    }

    // MARK: - Skeleton View

    private var skeletonView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let lines = skeletonLines, lines > 1 {
                ForEach(0..<lines, id: \.self) { index in
                    let width = index == lines - 1 ? 0.6 : 1.0
                    SkeletonLine(
                        height: skeletonHeight ?? 12,
                        width: width
                    )
                }
            } else {
                SkeletonLine(
                    height: skeletonHeight ?? 100,
                    width: 1.0
                )
            }
        }
        .padding(20)
    }

    // MARK: - Skeleton Line

    struct SkeletonLine: View {
        let height: CGFloat
        let width: CGFloat

        @State private var isAnimating = false

        var body: some View {
            RoundedRectangle(cornerRadius: 4)
                .fill(.quaternary)
                .frame(height: height)
                .frame(maxWidth: width * 300)
                .overlay(
                    SkeletonGradient()
                        .mask(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white)
                        )
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }

    struct SkeletonGradient: View {
        @State private var position: CGPoint = .zero

        let gradient = Gradient(
            colors: [
                .clear,
                Color.white.opacity(0.3),
                .clear
            ]
        )

        var body: some View {
            GeometryReader { geometry in
                LinearGradient(
                    gradient: gradient,
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: geometry.size.width)
                .offset(x: position.x - geometry.size.width)
                .onAppear {
                    withAnimation(
                        Animation.linear(duration: 1.5)
                            .repeatForever(autoreverses: false)
                    ) {
                        position = CGPoint(x: geometry.size.width * 2, y: 0)
                    }
                }
            }
        }
    }
}

// MARK: - Convenient Initializers

extension LoadingView {

    /// Create a small loading spinner
    ///
    /// 创建小型加载加载器
    ///
    /// - Parameter message: The loading message / 加载消息（可选）
    public static func small(_ message: String? = nil) -> Self {
        LoadingView(message, style: .small)
    }

    /// Create a large loading spinner
    ///
    /// 创建大型加载加载器
    ///
    /// - Parameter message: The loading message / 加载消息（可选）
    public static func large(_ message: String? = nil) -> Self {
        LoadingView(message, style: .large)
    }

    /// Create a skeleton loading view with custom height
    ///
    /// 创建自定义高度的骨架屏加载视图
    ///
    /// - Parameters:
    ///   - height: The skeleton height / 骨架高度
    ///   - lines: The number of lines / 行数
    public static func skeleton(
        height: CGFloat,
        lines: Int = 1
    ) -> Self {
        LoadingView(skeletonHeight: height, lines: lines)
    }

    /// Create a skeleton loading view with multiple lines
    ///
    /// 创建多行骨架屏加载视图
    ///
    /// - Parameter lines: The number of lines / 行数
    public static func skeleton(lines: Int) -> Self {
        LoadingView(skeletonHeight: 12, lines: lines)
    }
}

// MARK: - View Extensions

extension View {

    /// Overlay a loading view on this view
    ///
    /// 在此视图上叠加加载视图
    ///
    /// - Parameters:
    ///   - isLoading: Whether to show loading / 是否显示加载
    ///   - message: The loading message / 加载消息（可选）
    /// - Returns: A view that conditionally shows loading / 条件显示加载的视图
    public func loading(
        _ isLoading: Bool,
        message: String? = nil
    ) -> some View {
        self.overlay(
            Group {
                if isLoading {
                    LoadingView(message)
                        .background(.ultraThinMaterial)
                }
            }
        )
    }

    /// Overlay a progress loading view on this view
    ///
    /// 在此视图上叠加进度加载视图
    ///
    /// - Parameters:
    ///   - progress: The progress value / 进度值
    ///   - message: The loading message / 加载消息（可选）
    /// - Returns: A view that shows progress / 显示进度的视图
    public func loadingProgress(
        _ progress: Double,
        message: String? = nil
    ) -> some View {
        self.overlay(
            LoadingView(progress: progress, message: message)
                .padding(20)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
        )
    }
}

// MARK: - Preview

#if DEBUG
struct LoadingView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Medium spinner
            LoadingView("Loading...")
                .previewDisplayName("Medium Spinner")

            // Small spinner
            LoadingView.small("Loading...")
                .previewDisplayName("Small Spinner")

            // Large spinner
            LoadingView.large("Please wait...")
                .previewDisplayName("Large Spinner")

            // Progress
            LoadingView(progress: 0.7, message: "Downloading...")
                .previewDisplayName("Progress")

            // Progress without message
            LoadingView(progress: 0.45)
                .previewDisplayName("Progress Only")

            // Skeleton single line
            LoadingView.skeleton(height: 100)
                .frame(width: 300)
                .previewDisplayName("Skeleton Single")

            // Skeleton multiple lines
            LoadingView.skeleton(lines: 3)
                .frame(width: 300)
                .previewDisplayName("Skeleton Lines")

            // Overlay example
            Color.clear
                .frame(width: 200, height: 200)
                .loading(true, message: "Loading data...")
                .previewDisplayName("Overlay")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
