import SwiftUI

struct MarketplaceInstallProgress: View {
    let phase: SkillManager.Phase

    var body: some View {
        HStack(spacing: Metrics.spacingS) {
            ProgressView()
                .controlSize(.small)
            Text(title)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, Metrics.spacingL)
        .padding(.vertical, Metrics.spacingS)
        .glassEffect()
    }

    private var title: String {
        switch phase {
        case .installing: String(localized: "Installing…")
        case .updating: String(localized: "Updating…")
        case .removing: String(localized: "Removing…")
        }
    }
}
