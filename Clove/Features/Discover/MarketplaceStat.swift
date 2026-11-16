import SwiftUI

struct MarketplaceStat<Value: View>: View {
    let title: LocalizedStringResource
    @ViewBuilder let value: Value

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            value
                .font(.body.weight(.medium))
                .monospacedDigit()
        }
        .accessibilityElement(children: .combine)
    }
}
