import SwiftUI

/// Keeps the panel visible while you work in another app, so it can sit beside
/// an editor or terminal.
struct PanelPinButton: View {
    @Environment(AppModel.self) private var model

    private var isPinned: Bool {
        model.settings.keepPanelOnTop
    }

    var body: some View {
        Button {
            model.settings.keepPanelOnTop.toggle()
        } label: {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .font(.system(size: 11, weight: .medium))
                .rotationEffect(.degrees(isPinned ? 0 : 30))
        }
        .buttonStyle(.plain)
        .foregroundStyle(isPinned ? Color.accentColor : .secondary)
        .help(isPinned ? String(localized: "Unpin. The panel hides when you switch apps.") : String(localized: "Pin beside your editor"))
        .accessibilityLabel(isPinned ? String(localized: "Unpin panel") : String(localized: "Pin panel"))
        .accessibilityAddTraits(isPinned ? .isSelected : [])
    }
}
