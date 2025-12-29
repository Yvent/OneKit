//
//  EmptyStateView.swift
//  OneKitCore
//
//  Created by OneKit
//

import SwiftUI

/// A view that displays an empty state with optional icon, title, description, and action
///
/// 显示空状态的视图，支持可选的图标、标题、描述和操作按钮
///
/// **Basic Usage:**
/// ```swift
/// EmptyStateView(
///     icon: "tray",
///     title: "No Data",
///     message: "Get started by adding your first item"
/// )
/// ```
///
/// **With Action:**
/// ```swift
/// EmptyStateView(
///     icon: "tray",
///     title: "No Items",
///     message: "Tap the button below to add your first item",
///     actionTitle: "Add Item",
///     action: { print("Add tapped") }
/// )
/// ```
///
/// **Custom Style:**
/// ```swift
/// EmptyStateView(
///     icon: "magnifyingglass",
///     title: "No Results",
///     message: "Try a different search term",
///     style: .compact
/// )
/// ```
public struct EmptyStateView: View {

    // MARK: - Styles

    /// Empty state style
    ///
    /// 空状态样式
    public enum Style {
        /// Full size with large icon and spacing
        /// 全尺寸大图标和大间距
        case full

        /// Compact size with smaller icon and spacing
        /// 紧凑尺寸小图标和小间距
        case compact
    }

    // MARK: - Properties

    /// The system icon name to display
    ///
    /// 要显示的系统图标名称
    let icon: String?

    /// The title text
    ///
    /// 标题文本
    let title: String

    /// The descriptive message text
    ///
    /// 描述性消息文本
    let message: String?

    /// The action button title
    ///
    /// 操作按钮标题
    let actionTitle: String?

    /// The action to perform when button is tapped
    ///
    /// 按钮点击时执行的操作
    let action: (() -> Void)?

    /// The empty state style
    ///
    /// 空状态样式
    let style: Style

    // MARK: - Initialization

    /// Create an empty state view
    ///
    /// 创建空状态视图
    ///
    /// - Parameters:
    ///   - icon: The system icon name / 系统图标名称
    ///   - title: The title text / 标题文本
    ///   - message: The descriptive message / 描述性消息（可选）
    ///   - actionTitle: The action button title / 操作按钮标题（可选）
    ///   - action: The action to perform / 要执行的操作（可选）
    ///   - style: The empty state style / 空状态样式（默认：.full）
    public init(
        icon: String? = nil,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil,
        style: Style = .full
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
        self.style = style
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: style == .full ? 20 : 12) {
            // Icon
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: style == .full ? 64 : 48))
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }

            // Title
            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            // Message
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(style == .full ? 40 : 20)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Convenient Initializers

extension EmptyStateView {

    /// Create an empty state view with SF Symbol icon
    ///
    /// 使用 SF Symbol 图标创建空状态视图
    ///
    /// - Parameters:
    ///   - icon: The SF Symbol name / SF Symbol 名称
    ///   - title: The title text / 标题文本
    ///   - message: The descriptive message / 描述性消息
    ///   - actionTitle: The action button title / 操作按钮标题
    ///   - action: The action to perform / 要执行的操作
    public static func withSymbol(
        _ icon: String,
        title: String,
        message: String? = nil,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) -> Self {
        EmptyStateView(
            icon: icon,
            title: title,
            message: message,
            actionTitle: actionTitle,
            action: action
        )
    }

    /// Create a compact empty state view
    ///
    /// 创建紧凑的空状态视图
    ///
    /// - Parameters:
    ///   - icon: The system icon name / 系统图标名称
    ///   - title: The title text / 标题文本
    ///   - message: The descriptive message / 描述性消息
    public static func compact(
        icon: String? = nil,
        title: String,
        message: String? = nil
    ) -> Self {
        EmptyStateView(
            icon: icon,
            title: title,
            message: message,
            style: .compact
        )
    }
}

// MARK: - Preview

#if DEBUG
struct EmptyStateView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            // Full style with icon and message
            EmptyStateView(
                icon: "tray",
                title: "No Items",
                message: "Get started by adding your first item"
            )
            .previewDisplayName("Full - With Message")

            // Full style with action
            EmptyStateView(
                icon: "tray",
                title: "No Items",
                message: "Tap the button below to add your first item",
                actionTitle: "Add Item",
                action: {}
            )
            .previewDisplayName("Full - With Action")

            // Compact style
            EmptyStateView(
                icon: "magnifyingglass",
                title: "No Results",
                message: "Try a different search term"
            )
            .previewDisplayName("Compact")

            // No icon
            EmptyStateView(
                title: "Coming Soon",
                message: "This feature will be available in the next update"
            )
            .previewDisplayName("No Icon")

            // Search results
            EmptyStateView.withSymbol(
                "magnifyingglass",
                title: "No Results Found",
                message: "We couldn't find anything matching your search"
            )
            .previewDisplayName("Search Results")
        }
        .previewLayout(.sizeThatFits)
    }
}
#endif
