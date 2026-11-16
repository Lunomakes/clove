import Foundation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: String(localized: "System", comment: "Follow the system language in Settings.")
        case .english: "English"
        case .simplifiedChinese: "简体中文"
        case .traditionalChinese: "繁體中文"
        }
    }

    init(languageCode: String?) {
        let components = languageCode?.lowercased().split(separator: "-") ?? []
        switch components.first {
        case "en": self = .english
        case "zh":
            switch components.dropFirst().first {
            case "hans", "cn", "sg": self = .simplifiedChinese
            case "hant", "tw", "hk", "mo": self = .traditionalChinese
            default: self = .system
            }
        default: self = .system
        }
    }
}
