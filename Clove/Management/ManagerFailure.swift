import Foundation

/// An install, update, or removal that failed, ready to show in an alert.
struct ManagerFailure: Error, Identifiable, Sendable {
    let id = UUID()
    let title: LocalizedStringResource
    let message: String

    init(title: LocalizedStringResource, error: any Error) {
        self.title = title
        message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
    }

    init(title: LocalizedStringResource, message: LocalizedStringResource) {
        self.title = title
        self.message = String(localized: message)
    }
}
