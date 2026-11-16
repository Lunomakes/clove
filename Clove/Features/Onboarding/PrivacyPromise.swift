import Foundation

struct PrivacyPromise: Identifiable, Hashable {
    let id: String
    let symbolName: String
    let title: String
    let detail: String

    static let all: [PrivacyPromise] = [
        PrivacyPromise(
            symbolName: "lock.shield",
            title: "Skills never leave your Mac",
            detail: "Nothing is uploaded, synced, or analyzed in the cloud."
        ),
        PrivacyPromise(
            symbolName: "hand.raised",
            title: "Changes only when you ask",
            detail: "Clove writes skill files only when you install, edit, or remove one. Anything replaced goes to the Trash."
        ),
        PrivacyPromise(
            symbolName: "externaldrive.badge.checkmark",
            title: "Your groups stay local",
            detail: "Saved in one JSON file inside Clove's Application Support folder."
        ),
        PrivacyPromise(
            symbolName: "wifi.slash",
            title: "No analytics",
            detail: "Discover talks to skills.sh and GitHub only while you browse or install. No telemetry, no skill uploads."
        ),
    ]

    init(symbolName: String, title: LocalizedStringResource, detail: LocalizedStringResource) {
        self.id = title.key
        self.symbolName = symbolName
        self.title = String(localized: title)
        self.detail = String(localized: detail)
    }

}
