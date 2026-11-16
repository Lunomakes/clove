import Foundation

struct FeatureHighlight: Identifiable, Hashable, Sendable {
    let id: String
    let symbolName: String
    let title: String
    let detail: String

    init(symbolName: String, title: LocalizedStringResource, detail: LocalizedStringResource) {
        self.id = title.key
        self.symbolName = symbolName
        self.title = String(localized: title)
        self.detail = String(localized: detail)
    }

}
