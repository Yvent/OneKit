//
//  DeviceNetwork.swift
//  OneKitCore
//
//  Created by zyw on 2025/12/24.
//

import Foundation
#if canImport(CoreTelephony)
import CoreTelephony
#endif

/// Device network information
///
/// 设备网络信息，用于获取运营商、IP地址等网络相关信息
///
public enum DeviceNetwork {

    // MARK: - Carrier Info

    /// Carrier information structure
    ///
    /// 运营商信息结构
    public struct CarrierInfo: CustomStringConvertible, Sendable {
        /// Carrier name (e.g., "中国移动", "China Mobile", "Verizon")
        /// 运营商名称
        public let name: String

        /// Unique carrier identifier (e.g., "china_mobile", "verizon", "softbank")
        /// 运营商唯一标识符
        public let identifier: String

        /// ISO country code (e.g., "cn", "us", "jp")
        /// ISO 国家代码
        public let countryCode: String?

        /// Mobile Country Code (MCC)
        /// 移动国家代码
        public let mcc: String?

        /// Mobile Network Code (MNC)
        /// 移动网络代码
        public let mnc: String?

        public var description: String {
            var info = "Carrier(name: \(name), identifier: \(identifier)"
            if let cc = countryCode {
                info += ", country: \(cc)"
            }
            if let mcc = mcc, let mnc = mnc {
                info += ", mcc: \(mcc), mnc: \(mnc)"
            }
            info += ")"
            return info
        }
    }

    /// Carrier information
    ///
    /// 运营商信息
    public static var carrierInfo: CarrierInfo? {
        #if canImport(CoreTelephony)
        #if os(iOS)
        let info = CTTelephonyNetworkInfo()
        let carrier: CTCarrier?

        if #available(iOS 12.0, *) {
            carrier = info.serviceSubscriberCellularProviders?.values.first
        } else {
            carrier = info.subscriberCellularProvider
        }

        guard let ctCarrier = carrier else {
            return nil
        }

        // Get raw data
        let carrierName = ctCarrier.carrierName ?? ""
        let isoCountryCode = ctCarrier.isoCountryCode
        let mcc = ctCarrier.mobileCountryCode
        let mnc = ctCarrier.mobileNetworkCode

        // Try to identify carrier by MCC/MNC first, then by name
        let identifier = identifyCarrier(mcc: mcc, mnc: mnc, name: carrierName)

        return CarrierInfo(
            name: carrierName,
            identifier: identifier,
            countryCode: isoCountryCode,
            mcc: mcc,
            mnc: mnc
        )
        #else
        return nil
        #endif
        #else
        return nil
        #endif
    }

    /// Carrier name (e.g., "中国移动", "China Mobile", "Verizon")
    ///
    /// 运营商名称
    public static var carrierName: String {
        return carrierInfo?.name ?? ""
    }

    /// Carrier type code
    ///
    /// 运营商类型代码
    ///
    /// Examples:
    /// - China: "china_mobile", "china_unicom", "china_telecom"
    /// - USA: "verizon", "at&t", "t_mobile"
    /// - Japan: "ntt_docomo", "softbank", "au"
    public static var carrierCode: String {
        return carrierInfo?.identifier ?? ""
    }

    // MARK: - Private - Carrier Identification

    /// Identify carrier by MCC/MNC or name
    ///
    /// 通过 MCC/MNC 或名称识别运营商
    private static func identifyCarrier(mcc: String?, mnc: String?, name: String) -> String {
        // Priority 1: Try MCC/MNC matching
        if let mcc = mcc, let mnc = mnc {
            let key = "\(mcc)-\(mnc)"
            if let identifier = carrierDatabase[key] {
                return identifier
            }

            // Try MCC-only matching (for multi-MNC carriers)
            if let mccIdentifiers = mccDatabase[mcc] {
                // Try name matching within MCC group
                for (carrierName, identifier) in mccIdentifiers {
                    if name.range(of: carrierName, options: .caseInsensitive) != nil {
                        return identifier
                    }
                }
            }
        }

        // Priority 2: Try name-based matching
        return identifyCarrierByName(name)
    }

    /// Identify carrier by name with international support
    ///
    /// 通过名称识别运营商（支持国际化）
    private static func identifyCarrierByName(_ name: String) -> String {
        let lowercasedName = name.lowercased()

        // China - 中国运营商
        if lowercasedName.contains("移动") || lowercasedName.contains("china mobile") {
            return "china_mobile"
        }
        if lowercasedName.contains("联通") || lowercasedName.contains("china unicom") ||
           lowercasedName.contains("unicom") {
            return "china_unicom"
        }
        if lowercasedName.contains("电信") || lowercasedName.contains("china telecom") ||
           lowercasedName.contains("telecom") {
            return "china_telecom"
        }
        if lowercasedName.contains("广电") || lowercasedName.contains("china broadnet") {
            return "china_broadnet"
        }

        // USA - 美国运营商
        if lowercasedName.contains("verizon") {
            return "verizon"
        }
        if lowercasedName.contains("at&t") || lowercasedName.contains("at&t mobility") {
            return "att"
        }
        if lowercasedName.contains("t-mobile") || lowercasedName.contains("tmobile") {
            return "t_mobile"
        }
        if lowercasedName.contains("sprint") {
            return "sprint"
        }

        // Japan - 日本运营商
        if lowercasedName.contains("ntt docomo") || lowercasedName.contains("docomo") {
            return "ntt_docomo"
        }
        if lowercasedName.contains("softbank") {
            return "softbank"
        }
        if lowercasedName.contains("au") || lowercasedName.contains("kddi") {
            return "au_kddi"
        }
        if lowercasedName.contains("rakuten") {
            return "rakuten"
        }

        // South Korea - 韩国运营商
        if lowercasedName.contains("sk telecom") {
            return "sk_telecom"
        }
        if lowercasedName.contains("kt") || lowercasedName.contains("olleh") {
            return "kt"
        }
        if lowercasedName.contains("lg u+") || lowercasedName.contains("lg uplus") {
            return "lg_uplus"
        }

        // UK - 英国运营商
        if lowercasedName.contains("ee") || lowercasedName.contains("everything everywhere") {
            return "ee"
        }
        if lowercasedName.contains("vodafone uk") || lowercasedName.contains("vodafone") {
            return "vodafone"
        }
        if lowercasedName.contains("o2") || lowercasedName.contains("telefonica") {
            return "o2"
        }
        if lowercasedName.contains("three") || lowercasedName.contains("3") {
            return "three"
        }

        // Germany - 德国运营商
        if lowercasedName.contains("telekom") || lowercasedName.contains("t-mobile") {
            return "telekom_de"
        }
        if lowercasedName.contains("vodafone de") {
            return "vodafone_de"
        }
        if lowercasedName.contains("o2 de") || lowercasedName.contains("o₂") {
            return "o2_de"
        }

        // France - 法国运营商
        if lowercasedName.contains("orange") {
            return "orange"
        }
        if lowercasedName.contains("sfr") {
            return "sfr"
        }
        if lowercasedName.contains("bouygues") {
            return "bouygues"
        }

        // India - 印度运营商
        if lowercasedName.contains("jio") || lowercasedName.contains("reliance") {
            return "jio"
        }
        if lowercasedName.contains("airtel") {
            return "airtel"
        }
        if lowercasedName.contains("vi") || lowercasedName.contains("vodafone idea") {
            return "vodafone_idea"
        }

        // Brazil - 巴西运营商
        if lowercasedName.contains("vivo") {
            return "vivo"
        }
        if lowercasedName.contains("tim") {
            return "tim_br"
        }
        if lowercasedName.contains("claro") {
            return "claro"
        }

        // Unknown carrier - return sanitized name as identifier
        return lowercasedName
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "-", with: "_")
            .filter { $0.isLetter || $0 == "_" || $0.isNumber }
    }

    /// Carrier database by MCC-MNC
    ///
    /// MCC-MNC 运营商数据库
    ///
    /// References:
    /// - https://mcc-mnc.com/
    /// - https://mcc-mnc.net/
    /// - https://en.wikipedia.org/wiki/Mobile_country_code
    private static let carrierDatabase: [String: String] = [
        // China - 中国
        "460-00": "china_mobile",
        "460-02": "china_mobile",
        "460-07": "china_mobile",
        "460-08": "china_mobile",
        "460-01": "china_unicom",
        "460-06": "china_unicom",
        "460-09": "china_unicom",
        "460-03": "china_telecom",
        "460-05": "china_telecom",
        "460-11": "china_telecom",
        "460-15": "china_broadnet", // China Broadnet (广电)

        // USA - 美国
        "310-260": "t_mobile",
        "310-026": "t_mobile",
        "310-410": "att",
        "310-070": "att",
        "310-150": "att",
        "310-380": "att",
        "311-480": "verizon",
        "310-004": "verizon",
        "310-590": "sprint",

        // Japan - 日本
        "440-10": "ntt_docomo",
        "440-11": "ntt_docomo",
        "440-20": "softbank",
        "440-08": "softbank",
        "440-50": "au_kddi",
        "440-51": "au_kddi",
        "440-54": "rakuten",

        // South Korea - 韩国
        "450-05": "sk_telecom",
        "450-08": "kt",
        "450-06": "lg_uplus",

        // UK - 英国
        "234-30": "ee",
        "234-31": "ee",
        "234-15": "vodafone",
        "234-10": "o2",
        "234-20": "three",

        // Germany - 德国
        "262-01": "telekom_de",
        "262-02": "vodafone_de",
        "262-03": "telekom_de",
        "262-07": "o2_de",
        "262-09": "o2_de",

        // France - 法国
        "208-01": "orange",
        "208-10": "sfr",
        "208-20": "bouygues",

        // India - 印度
        "404-01": "airtel",
        "404-02": "airtel",
        "404-97": "jio",
        "404-98": "jio",
        "404-99": "jio",
        "405-01": "vodafone_idea",

        // Brazil - 巴西
        "724-05": "claro",
        "724-06": "vivo",
        "724-10": "vivo",
        "724-16": "tim_br",

        // Canada - 加拿大
        "302-220": "telus",
        "302-610": "bell",
        "302-720": "rogers",
        "302-880": "freedom",

        // Australia - 澳大利亚
        "505-01": "telstra",
        "505-02": "optus",
        "505-03": "vodafone_au",

        // Singapore - 新加坡
        "525-01": "singtel",
        "525-02": "starhub",
        "525-03": "m1",

        // Hong Kong - 香港
        "454-00": "csl",
        "454-02": "smc",
        "454-06": "3_hk",
        "454-12": "cmhk",
        "454-16": "china_mobile_hk",
        "454-19": "smartone",

        // Taiwan - 台湾
        "466-01": "far_eastone",
        "466-06": "far_eastone",
        "466-89": "taiwan_mobile",
        "466-92": "taiwan_mobile",
        "466-99": "chunghwa",
        "466-97": "t_star",
        "466-11": "aptg",

        // Thailand - 泰国
        "520-00": "ais",
        "520-01": "ais",
        "520-18": "truemove",
        "520-99": "dtac",

        // Vietnam - 越南
        "452-01": "viettel",
        "452-02": "vinaphone",
        "452-04": "mobifone",
        "452-05": "vietnamobile",

        // Indonesia - 印度尼西亚
        "510-00": "telkomsel",
        "510-01": "indosat",
        "510-08": "xl_axiata",
        "510-10": "3_indonesia",

        // Philippines - 菲律宾
        "515-01": "globe_telecom",
        "515-02": "smart_communications",
        "515-03": "sun_cellular",
        "515-05": "globe_telecom",
        "515-18": "dito_telecommunity",

        // Malaysia - 马来西亚
        "502-12": "maxis",
        "502-16": "maxis",
        "502-17": "celcom",
        "502-19": "digi",

        // Spain - 西班牙
        "214-01": "vodafone_es",
        "214-03": "orange",
        "214-04": "yoigo",
        "214-07": "movistar",
        "214-21": "movistar",

        // Italy - 意大利
        "222-01": "tim_it",
        "222-10": "vodafone_it",
        "222-88": "wind_tre",
        "222-99": "iliad",

        // Netherlands - 荷兰
        "204-04": "vodafone_nl",
        "204-08": "kpn",
        "204-16": "t_mobile_nl",
        "204-20": "telenet",

        // Switzerland - 瑞士
        "228-01": "swisscom",
        "228-02": "sunrise",
        "228-03": "salt",

        // Sweden - 瑞典
        "240-01": "telia_se",
        "240-02": "telia_se",
        "240-04": "tele2_se",
        "240-05": "three_se",
        "240-07": "tele2_se",
        "240-08": "telenor_se",

        // Norway - 挪威
        "242-01": "telenor_no",
        "242-02": "telenor_no",
        "242-05": "telia_no",
        "242-07": "telia_no",
        "242-09": "ice",

        // Denmark - 丹麦
        "238-01": "tdc",
        "238-02": "telia_dk",
        "238-06": "tre_dk",
        "238-10": "norly_dk",
        "238-20": "ice_dk",

        // Poland - 波兰
        "260-01": "plus",
        "260-02": "t_mobile_pl",
        "260-03": "orange_pl",
        "260-06": "play",
        "260-10": "play",

        // Russia - 俄罗斯
        "250-01": "mts",
        "250-02": "megafon",
        "250-05": "beeline",
        "250-20": "tele2_ru",
        "250-99": "yota",

        // Mexico - 墨西哥
        "334-020": "telcel",
        "334-010": "att_mx",
        "334-030": "movistar_mx",
        "334-050": "at&t_mx",

        // Argentina - 阿根廷
        "722-010": "personal",
        "722-020": "movistar_ar",
        "722-070": "claro_ar",
        "722-310": "personal",
        "722-320": "movistar_ar",
        "722-330": "claro_ar",

        // Colombia - 哥伦比亚
        "732-001": "colombian_mobile",
        "732-002": "movistar_co",
        "732-003": "claro_co",
        "732-009": "tigo_co",
        "732-010": "uff_movil",
        "732-102": "movistar_co",
        "732-103": "claro_co",
        "732-123": "tigo_co",
        "732-999": "wom_co",

        // Chile - 智利
        "730-001": "entel",
        "730-002": "movistar_cl",
        "730-003": "claro_cl",
        "730-010": "entel",
        "730-090": "wom_cl",
        "730-110": "claro_cl",
        "730-220": "movistar_cl",

        // Peru - 秘鲁
        "716-001": "entel_pe",
        "716-006": "movistar_pe",
        "716-010": "claro_pe",
        "716-015": "entel_pe",
        "716-017": "bitel",
        "716-040": "entel_pe",

        // South Africa - 南非
        "655-01": "vodafone_za",
        "655-02": "mtn",
        "655-06": "cell_c",
        "655-07": "telkom_za",
        "655-10": "vodacom_za",
        "655-11": "mtn_za",
        "655-21": "rain",

        // Egypt - 埃及
        "602-01": "orange_eg",
        "602-02": "vodafone_eg",
        "602-03": "etisalat_eg",
        "602-04": "we_eg",
        "602-05": "etisalat_eg",
        "602-99": "orange_eg",

        // Saudi Arabia - 沙特阿拉伯
        "420-01": "stc",
        "420-02": "mobily",
        "420-03": "zain_sa",
        "420-04": "zain_sa",
        "420-05": "mobily",

        // UAE - 阿联酋
        "424-01": "etisalat_ae",
        "424-02": "du",
        "424-03": "etisalat_ae",
        "424-04": "du",
        "424-05": "swt_ae",

        // Israel - 以色列
        "425-01": "pelephone",
        "425-02": "cellcom",
        "425-03": "hot_mobile",
        "425-05": "golan_telecom",
        "425-06": "wecom",
        "425-07": "hot_mobile",
        "425-08": "cellcom",
        "425-10": "hot_mobile",
        "425-11": "sttv_il",
        "425-12": "pelephone",
        "425-14": "cellcom",
        "425-15": "wecom",
        "425-16": "golan_telecom",
        "425-17": "home_cellular",
        "425-18": "cellcom",
        "425-19": "cellcom",
        "425-21": "hot_mobile",
        "425-22": "wecom",
        "425-23": "hot_mobile",
        "425-25": "hot_mobile",
        "425-26": "hot_mobile",
        "425-27": "hot_mobile",
        "425-28": "hot_mobile",
        "425-29": "hot_mobile",
        "425-31": "hot_mobile",
        "425-32": "hot_mobile",
        "425-33": "hot_mobile",
        "425-35": "hot_mobile",
        "425-77": "pelephone",
        "425-85": "hot_mobile",
        "425-86": "hot_mobile",
        "425-87": "hot_mobile",
        "425-88": "hot_mobile",
        "425-89": "hot_mobile",
        "425-99": "cellcom",

        // Turkey - 土耳其
        "286-01": "turkcell",
        "286-02": "turk_telekom",
        "286-03": "vodafone_tr",

        // Pakistan - 巴基斯坦
        "410-01": "jazz",
        "410-02": "telenor_pk",
        "410-03": "ufone",
        "410-04": "zong_pk",
        "410-05": "zong_pk",
        "410-06": "jazz",
        "410-07": "telenor_pk",

        // Bangladesh - 孟加拉国
        "470-01": "grameenphone",
        "470-02": "robi",
        "470-03": "banglalink",
        "470-04": "teletalk",

        // Nigeria - 尼日利亚
        "621-20": "mtn_ng",
        "621-30": "airtel_ng",
        "621-40": "9mobile",
        "621-50": "glo_ng",
        "621-60": "mtn_ng",
        "621-80": "airtel_ng",
        "621-90": "9mobile",

        // Kenya - 肯尼亚
        "639-02": "safaricom",
        "639-03": "airtel_ke",
        "639-05": "telkom_ke",
        "639-07": "faiba_4g",
        "639-10": "safaricom",

        // Morocco - 摩洛哥
        "604-00": "iam",
        "604-01": "iam",
        "604-02": "inwi",
        "604-06": "orange_ma",
        "604-07": "orange_ma",

        // Algeria - 阿尔及利亚
        "603-01": "mobilis",
        "603-02": "djezzy",
        "603-03": "ooredoo_dz",

        // Tunisia - 突尼斯
        "605-01": "tunisie_telecom",
        "605-02": "ooredoo_tn",
        "605-03": "orange_tn",

        // New Zealand - 新西兰
        "530-01": "vodafone_nz",
        "530-02": "spark_nz",
        "530-05": "skinny",
        "530-24": "2degrees_nz",
        "530-04": "spark_nz",
    ]

    /// MCC to carrier names mapping (for multi-MNC carriers)
    ///
    /// MCC 到运营商名称的映射（用于多 MNC 运营商）
    private static let mccDatabase: [String: [(String, String)]] = [
        "460": [("中国移动", "china_mobile"),
               ("中国联通", "china_unicom"),
               ("中国电信", "china_telecom"),
               ("中国广电", "china_broadnet")],
        "310": [("Verizon", "verizon"),
                ("AT&T", "att"),
                ("T-Mobile", "t_mobile")],
        "440": [("NTT DOCOMO", "ntt_docomo"),
                ("SoftBank", "softbank"),
                ("au", "au_kddi"),
                ("Rakuten", "rakuten")],
        "234": [("EE", "ee"),
                ("Vodafone", "vodafone"),
                ("O2", "o2"),
                ("Three", "three")],
        "262": [("Telekom", "telekom_de"),
                ("Vodafone", "vodafone_de"),
                ("O2", "o2_de")],
        "208": [("Orange", "orange"),
                ("SFR", "sfr"),
                ("Bouygues", "bouygues")],
        "404": [("Airtel", "airtel"),
                ("Jio", "jio"),
                ("Vodafone", "vodafone_idea")],
        "724": [("Vivo", "vivo"),
                ("TIM", "tim_br"),
                ("Claro", "claro")],
        "302": [("Telus", "telus"),
                ("Bell", "bell"),
                ("Rogers", "rogers")],
        "505": [("Telstra", "telstra"),
                ("Optus", "optus"),
                ("Vodafone", "vodafone_au")],
        "525": [("Singtel", "singtel"),
                ("StarHub", "starhub"),
                ("M1", "m1")],
    ]

    // MARK: - IP Address

    /// Current device IP address (IPv4 or IPv6)
    ///
    /// 当前设备IP地址（IPv4 或 IPv6）
    public static var ipAddress: String {
        var addresses = [String]()
        var ifaddr: UnsafeMutablePointer<ifaddrs>?

        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee

                // Check for running, non-loopback interfaces
                if (flags & (IFF_UP | IFF_RUNNING | IFF_LOOPBACK)) == (IFF_UP | IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if getnameinfo(
                            &addr,
                            socklen_t(addr.sa_len),
                            &hostname,
                            socklen_t(hostname.count),
                            nil,
                            socklen_t(0),
                            NI_NUMERICHOST
                        ) == 0 {
                            // Use String(validatingUTF8:) to handle hostname
                            if let address = String(validatingUTF8: hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }

        return addresses.first ?? ""
    }
}
