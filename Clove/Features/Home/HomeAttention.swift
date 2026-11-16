import SwiftUI

/// Something on this Mac that's worth a look, and where to deal with it.
struct HomeAttention: Identifiable {
    let id: String
    let title: LocalizedStringResource
    let detail: LocalizedStringResource
    let symbolName: String
    let destination: SidebarItem
    /// Some items are fixed in System Settings, not in Clove.
    var action: Action?
    /// Warnings lead the list and carry the warning tint.
    var isWarning = false

    enum Action {
        case fullDiskAccess
        case accessibility

        var title: String {
            switch self {
            case .fullDiskAccess, .accessibility: String(localized: "Allow…")
            }
        }

        @MainActor
        func perform() {
            switch self {
            case .fullDiskAccess: StorageStore.openFullDiskAccessSettings()
            case .accessibility: AccessibilityAccess.openSettings()
            }
        }
    }

    @MainActor
    static func items(in model: AppModel) -> [HomeAttention] {
        var items: [HomeAttention] = []

        // The disk first: it's what most people open Clove for.
        let storage = model.storage
        if let volume = storage.volume, volume.capacity > 0 {
            let fullness = Double(volume.used) / Double(volume.capacity)
            if fullness >= 0.9 || volume.available < 20_000_000_000 {
                items.append(HomeAttention(
                    id: "low-space",
                    title: LocalizedStringResource("Your Mac is \(Int((fullness * 100).rounded()))% full"),
                    detail: LocalizedStringResource("\(StorageFormat.gb(volume.available)) left. See what's taking up the space."),
                    symbolName: "internaldrive.badge.exclamationmark",
                    destination: .storage,
                    isWarning: true
                ))
            }
        }
        if let clean = storage.recommendation, clean == .caches {
            items.append(HomeAttention(
                id: "caches",
                title: LocalizedStringResource("\(StorageFormat.gb(storage.clearableBytes(for: .caches))) of caches to clear"),
                detail: storage.trashFirst ? LocalizedStringResource("Safe to clear. They go to the Trash first.") : LocalizedStringResource("Safe to clear. Apps rebuild them as needed."),
                symbolName: "square.stack.3d.up",
                destination: .storage
            ))
        }

        // Permissions Clove works without, but less well. Each one says what it unlocks.
        if storage.reports[.trash]?.isRestricted == true {
            items.append(HomeAttention(
                id: "full-disk-access",
                title: LocalizedStringResource("See what's in your Trash"),
                detail: LocalizedStringResource("Clove needs Full Disk Access to measure and empty it."),
                symbolName: "lock.shield",
                destination: .storage,
                action: .fullDiskAccess
            ))
        }
        if !AccessibilityAccess.isGranted {
            items.append(HomeAttention(
                id: "accessibility",
                title: LocalizedStringResource("Insert skills into any app"),
                detail: LocalizedStringResource("Clove needs Accessibility access to type into your editor."),
                symbolName: "hand.raised",
                destination: .home,
                action: .accessibility
            ))
        }

        let updates = model.manager.updatesAvailable.count
        if updates > 0 {
            items.append(HomeAttention(
                id: "updates",
                title: LocalizedStringResource("\(updates) skills have updates"),
                detail: LocalizedStringResource("Newer versions are on skills.sh."),
                symbolName: "arrow.down.circle",
                destination: .library(.all)
            ))
        }

        let candidates = model.cleanupCandidates
        if !candidates.isEmpty {
            let tokens = candidates.reduce(0) { $0 + $1.tokens }
            items.append(HomeAttention(
                id: "unused",
                title: LocalizedStringResource("\(candidates.count) skills you don't use"),
                detail: LocalizedStringResource("They take up \(tokens.formatted()) tokens in every agent session."),
                symbolName: "leaf",
                destination: .cleanup
            ))
        }

        let leftoverBytes = (model.cleanup.leftovers.value ?? []).filter(\.isOutdated).reduce(Int64(0)) { $0 + $1.bytes }
        if leftoverBytes > 0 {
            items.append(HomeAttention(
                id: "leftovers",
                title: LocalizedStringResource("Old agent downloads"),
                detail: LocalizedStringResource("\(leftoverBytes.formatted(.byteCount(style: .file))) of browsers and packages agents left behind."),
                symbolName: "shippingbox",
                destination: .cleanup
            ))
        }

        let history = Int64(model.cleanup.oldTranscripts.reduce(0) { $0 + $1.size })
        if history > 0 {
            items.append(HomeAttention(
                id: "history",
                title: LocalizedStringResource("Old conversations"),
                detail: LocalizedStringResource("\(history.formatted(.byteCount(style: .file))) of saved agent transcripts."),
                symbolName: "clock.arrow.circlepath",
                destination: .cleanup
            ))
        }

        let findings = model.secrets.findings.count
        if findings > 0 {
            items.append(HomeAttention(
                id: "secrets",
                title: LocalizedStringResource("\(findings) API keys in plain text"),
                detail: LocalizedStringResource("They're in your shell profile. Move them to the Keychain."),
                symbolName: "key",
                destination: .secrets
            ))
        }

        let devServers = model.running.items(of: .devServer).count
        if devServers > 0 {
            items.append(HomeAttention(
                id: "servers",
                title: LocalizedStringResource("\(devServers) dev servers still running"),
                detail: LocalizedStringResource("Stop the ones you're done with."),
                symbolName: "server.rack",
                destination: .running
            ))
        }

        return items
    }
}
