//
//  UIView+Extensions.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/30.
//

#if canImport(UIKit)
import UIKit

// MARK: - Radius Type

/// Corner radius type for selective corner rounding
/// 选择性圆角类型
enum RadiusType {
    /// All four corners / 四边圆角
    case radiusAll

    /// Top two corners / 上圆角
    case radiusTop

    /// Left two corners / 左圆角
    case radiusLeft

    /// Bottom two corners / 下圆角
    case radiusBottom

    /// Right two corners / 右圆角
    case radiusRight

    /// Top-left corner / 上左角
    case radiusTopleft

    /// Top-right corner / 上右角
    case radiusTopright

    /// Bottom-left corner / 下左角
    case radiusBottomleft

    /// Bottom-right corner / 下右角
    case radiusBottomright

    /// Converts RadiusType to UIRectCorner
    /// 将 RadiusType 转换为 UIRectCorner
    var rectCorners: UIRectCorner {
        switch self {
        case .radiusAll:
            return .allCorners
        case .radiusTop:
            return [.topLeft, .topRight]
        case .radiusLeft:
            return [.topLeft, .bottomLeft]
        case .radiusBottom:
            return [.bottomLeft, .bottomRight]
        case .radiusRight:
            return [.topRight, .bottomRight]
        case .radiusTopleft:
            return .topLeft
        case .radiusTopright:
            return .topRight
        case .radiusBottomleft:
            return .bottomLeft
        case .radiusBottomright:
            return .bottomRight
        }
    }
}

// MARK: - View Hierarchy

extension UIView {

    /// Adds multiple subviews at once
    /// 批量添加子视图
    ///
    /// - Parameter views: Array of views to add as subviews / 要添加的视图数组
    func addSubviews(_ views: [UIView]) {
        views.forEach { addSubview($0) }
    }

    /// Sets hidden state for multiple views at once
    /// 批量设置视图的隐藏状态
    ///
    /// - Parameters:
    ///   - views: Array of views to modify / 要修改的视图数组
    ///   - isHidden: Whether views should be hidden / 是否隐藏
    func setSubviewsHidden(_ views: [UIView], isHidden: Bool) {
        views.forEach { $0.isHidden = isHidden }
    }
}

// MARK: - Corner Radius

extension UIView {

    /// Applies corner radius to specific corners
    /// 为指定边角设置圆角
    ///
    /// - Parameters:
    ///   - type: Which corners to round / 圆角类型
    ///   - cornerRadius: Radius of the corners / 圆角半径
    func layoutCornerRadius(type: RadiusType, cornerRadius: CGFloat) {
        let corners = type.rectCorners
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
        )

        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = path.cgPath

        layer.mask = maskLayer
        layer.masksToBounds = true
    }
}

// MARK: - Image Conversion

extension UIView {

    /// Converts view to UIImage
    /// 将视图转换为图片
    ///
    /// - Returns: Image representation of the view / 视图的图片表示
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, isOpaque, 0.0)
        defer {
            UIGraphicsEndImageContext()
        }

        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }

        layer.render(in: context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

#endif
