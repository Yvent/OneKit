//
//  View+Haptic.swift
//  OneKitUI
//
//  Created by OneKit
//

#if canImport(SwiftUI)
import SwiftUI

@available(iOS 15.0, *)
public extension View {

    /// Add haptic feedback to the view
    ///
    /// 添加触觉反馈
    ///
    /// This modifier provides a unified API for haptic feedback across iOS versions.
    /// On iOS 17+, it uses the native `.sensoryFeedback` modifier.
    /// On iOS 15-16, it falls back to UIKit's FeedbackGenerator.
    ///
    /// 提供统一的触觉反馈API，自动适配iOS版本。
    /// iOS 17+ 使用原生的 `.sensoryFeedback`，
    /// iOS 15-16 回退到 UIKit 的 FeedbackGenerator。
    ///
    /// **Usage with trigger (reactive):**
    /// ```swift
    /// @State private var count = 0
    ///
    /// Button("Increment") {
    ///     count += 1
    /// }
    /// .haptic(.increase, trigger: count)
    /// ```
    ///
    /// **Usage without trigger (manual):**
    /// ```swift
    /// Button("Tap Me") {
    ///     // Action
    /// }
    /// .haptic(.impact(.light))
    /// ```
    ///
    /// - Parameters:
    ///   - feedback: The type of haptic feedback / 触觉反馈类型
    ///   - trigger: An optional value to monitor for changes / 监听变化的可选值
    /// - Returns: A view that adds haptic feedback / 添加了触觉反馈的视图
    @MainActor
    @ViewBuilder
    func haptic(_ feedback: HapticFeedback, trigger: (some Equatable)? = nil) -> some View {
        if let trigger = trigger {
            // With trigger: reactive mode
            self.modifier(HapticTriggerModifier(feedback: feedback, trigger: trigger))
        } else {
            // Without trigger: manual trigger on tap
            self.onTapGesture {
                feedback.trigger()
            }
        }
    }
}

// MARK: - Haptic Feedback Types

/// Haptic feedback types
///
/// 触觉反馈类型
public enum HapticFeedback {

    /// Selection feedback (light tap)
    ///
    /// 选择反馈（轻微震动）
    case selection

    /// Impact feedback with intensity
    ///
    /// 冲击反馈，带强度
    case impact(ImpactIntensity)

    /// Success notification
    ///
    /// 成功通知
    case success

    /// Warning notification
    ///
    /// 警告通知
    case warning

    /// Error notification
    ///
    /// 错误通知
    case error

    /// Increase in value
    ///
    /// 数值增加
    case increase

    /// Decrease in value
    ///
    /// 数值减少
    case decrease

    /// Start action
    ///
    /// 开始动作
    case start

    /// Stop action
    ///
    /// 停止动作
    case stop

    /// Trigger the haptic feedback manually
    ///
    /// 手动触发触觉反馈
    @MainActor
    public func trigger() {
        #if os(iOS)
        switch self {
        case .selection:
            UISelectionFeedbackGenerator().selectionChanged()

        case .impact(let intensity):
            let generator = UIImpactFeedbackGenerator(style: intensity.uiKitStyle)
            generator.impactOccurred()

        case .success:
            UINotificationFeedbackGenerator().notificationOccurred(.success)

        case .warning:
            UINotificationFeedbackGenerator().notificationOccurred(.warning)

        case .error:
            UINotificationFeedbackGenerator().notificationOccurred(.error)

        case .increase, .decrease, .start, .stop:
            // Use medium impact for these on iOS < 17
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        #endif
    }

    #if swift(>=5.9)
    @available(iOS 17.0, macOS 14.0, *)
    var sensoryFeedbackType: SensoryFeedback {
        switch self {
        case .selection:
            return .selection
        case .impact(let intensity):
            switch intensity {
            case .light: return .impact(weight: .light)
            case .medium: return .impact(weight: .medium)
            case .heavy: return .impact(weight: .heavy)
            }
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        case .increase:
            return .increase
        case .decrease:
            return .decrease
        case .start:
            return .start
        case .stop:
            return .stop
        }
    }
    #endif
}

/// Impact intensity levels
///
/// 冲击强度级别
public enum ImpactIntensity {

    /// Light impact
    ///
    /// 轻度冲击
    case light

    /// Medium impact
    ///
    /// 中度冲击
    case medium

    /// Heavy impact
    ///
    /// 重度冲击
    case heavy

    #if os(iOS)
    /// Convert to UIKit UIImpactFeedbackGenerator style
    ///
    /// 转换为 UIKit 的 UIImpactFeedbackGenerator 样式
    var uiKitStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .light:
            return .light
        case .medium:
            return .medium
        case .heavy:
            return .heavy
        }
    }
    #endif
}

// MARK: - Haptic Trigger Modifier

/// Internal modifier to handle trigger changes
///
/// 内部修饰符，处理触发器变化
@available(iOS 15.0, *)
private struct HapticTriggerModifier<T: Equatable>: ViewModifier {
    let feedback: HapticFeedback
    let trigger: T

    @MainActor
    func body(content: Content) -> some View {
        #if swift(>=5.9)
        if #available(iOS 17.0, macOS 14.0, *) {
            // Use native sensoryFeedback
            content.sensoryFeedback(feedback.sensoryFeedbackType, trigger: trigger)
        } else {
            // Fallback to UIKit with onChange (iOS 16)
            content
                .onChange(of: trigger) { _ in
                    feedback.trigger()
            }
        }
        #else
        // Always use UIKit fallback (Swift < 5.9 or iOS < 17)
        content
            .onChange(of: trigger) { _ in
                feedback.trigger()
        }
        #endif
    }
}

#endif
