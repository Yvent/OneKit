//
//  AppInfo.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/23.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// AppInfo
///
/// A unified entry point for accessing application-related information,
/// such as app name, version, App Store links, and support contact.
///
/// 应用信息统一入口，用于获取应用名称、版本号、
/// App Store 链接、支持邮箱等应用级信息。
///
public enum AppInfo {

    // MARK: - Bundle Info

    /// Main bundle info dictionary
    ///
    /// 主 Bundle 的 infoDictionary
    private nonisolated(unsafe) static let infoDictionary = Bundle.main.infoDictionary

    /// Localized info dictionary
    ///
    /// 本地化后的 infoDictionary（优先用于展示）
    private nonisolated(unsafe) static let localizedInfoDictionary = Bundle.main.localizedInfoDictionary

    /// Application display name
    ///
    /// 应用显示名称（优先读取本地化配置）
    public static var appName: String {
        (localizedInfoDictionary?["CFBundleDisplayName"] as? String)
        ?? (infoDictionary?["CFBundleDisplayName"] as? String)
        ?? ""
    }

    /// Application version (CFBundleShortVersionString)
    ///
    /// 应用版本号（如 1.2.0）
    public static var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// Application build number (CFBundleVersion)
    ///
    /// 应用构建号（Build Number）
    public static var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    // MARK: - Configurable Values

    /// Support email address
    ///
    /// 客服支持邮箱（可选）
    public nonisolated(unsafe) private(set) static var supportEmail: String?

    /// App Store ID
    ///
    /// App Store 应用 ID（可选，TestFlight / 企业包可不配置）
    public nonisolated(unsafe) private(set) static var appStoreID: String?

    /// Privacy policy URL
    ///
    /// 隐私协议链接（可选）
    public nonisolated(unsafe) private(set) static var privacyPolicyURL: URL?

    /// Terms of service URL
    ///
    /// 使用条款链接（可选）
    public nonisolated(unsafe) private(set) static var termsOfServiceURL: URL?

    // MARK: - App Store URLs

    /// App Store product page URL
    ///
    /// App Store 应用详情页链接
    public static var appStoreURL: URL? {
        guard let appStoreID else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    /// App Store review (rating) URL
    ///
    /// App Store 评分 / 评论页面链接
    public static var appStoreReviewURL: URL? {
        guard let appStoreID else { return nil }
        return URL(
            string: "https://apps.apple.com/app/id\(appStoreID)?action=write-review"
        )
    }

    // MARK: - Configuration

    /// Configure optional app-related information
    ///
    /// 在应用启动时配置可选的应用信息
    ///
    /// - Parameters:
    ///   - supportEmail: Support email address / 客服邮箱
    ///   - appStoreID: App Store ID / App Store 应用 ID
    ///   - privacyPolicyURL: Privacy policy URL / 隐私协议链接
    ///   - termsOfServiceURL: Terms of service URL / 使用条款链接
    ///
    public static func configure(
        supportEmail: String? = nil,
        appStoreID: String? = nil,
        privacyPolicyURL: URL? = nil,
        termsOfServiceURL: URL? = nil
    ) {
        self.supportEmail = supportEmail
        self.appStoreID = appStoreID
        self.privacyPolicyURL = privacyPolicyURL
        self.termsOfServiceURL = termsOfServiceURL
    }
}
