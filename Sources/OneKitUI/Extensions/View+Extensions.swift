//
//  View+Extensions.swift
//  OneKitUI
//
//  Created by zyw on 2025/12/24.
//

#if canImport(SwiftUI)
import SwiftUI

public extension View {

    // MARK: - Conditional Modifiers

    /// Conditionally hide the view
    ///
    /// 条件隐藏视图
    ///
    /// Example:
    /// ```swift
    /// Text("Hello").hidden(shouldHide)
    /// ```
    /// - Parameter shouldHide: Whether to hide the view / 是否隐藏视图
    /// - Returns: Hidden view if shouldHide is true, otherwise the original view
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }

    /// Set accessibility identifier only if the identifier is not nil
    ///
    /// 仅当标识符不为 nil 时设置 accessibility identifier
    ///
    /// Example:
    /// ```swift
    /// Text("Username").accessibilityIdentifierIfAny(username)
    /// ```
    /// - Parameter identifier: Optional accessibility identifier / 可选的 accessibility identifier
    /// - Returns: View with accessibility identifier set if not nil
    @ViewBuilder func accessibilityIdentifierIfAny(_ identifier: String?) -> some View {
        if let identifier = identifier {
            self.accessibilityIdentifier(identifier)
        } else {
            self
        }
    }
}
#endif
