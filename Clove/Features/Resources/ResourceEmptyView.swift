import SwiftUI

/// Teaches what belongs in an empty list and where it would come from.
struct ResourceEmptyView: View {
    let kind: ResourceKind
    let query: String
    let isScanning: Bool

    var body: some View {
        if isScanning {
            ProgressView()
                .controlSize(.small)
        } else if !query.isEmpty {
            ContentUnavailableView.search(text: query)
        } else {
            CalmEmptyState(title: kind.emptyTitle, message: kind.emptyMessage) {
                ResourceArt(kind: kind)
            }
        }
    }
}
