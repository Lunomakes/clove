import Foundation

/// How long a skill can sit idle before Cleanup suggests removing it.
enum CleanupWindow: Int, CaseIterable, Identifiable, Sendable {
    case month = 30
    case quarter = 90
    case halfYear = 180

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .month: String(localized: "30 Days")
        case .quarter: String(localized: "90 Days")
        case .halfYear: String(localized: "6 Months")
        }
    }

    var phrase: String {
        switch self {
        case .month: String(localized: "30 days")
        case .quarter: String(localized: "90 days")
        case .halfYear: String(localized: "6 months")
        }
    }

    func cutoff(from now: Date = .now) -> Date {
        now.addingTimeInterval(-Double(rawValue) * 86_400)
    }
}
