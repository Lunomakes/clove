import SwiftUI

enum SettingsPane: String, CaseIterable, Identifiable {
    case general
    case sources
    case shortcuts
    case privacy
    case about

    var id: String { rawValue }

    static var visibleCases: [SettingsPane] { allCases }

    var title: String {
        switch self {
        case .general: String(localized: "General")
        case .sources: String(localized: "Folders")
        case .shortcuts: String(localized: "Shortcuts")
        case .privacy: String(localized: "Privacy")
        case .about: String(localized: "About")
        }
    }

    var symbolName: String {
        switch self {
        case .general: "gearshape"
        case .sources: "folder"
        case .shortcuts: "keyboard"
        case .privacy: "lock.shield"
        case .about: "info.circle"
        }
    }
}
