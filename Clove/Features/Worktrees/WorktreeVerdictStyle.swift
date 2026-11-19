import SwiftUI

/// How a verdict reads at a glance: one colour for the lane and its mark, a
/// symbol, and a two-word label. Colour only where it carries meaning.
extension WorktreeVerdict {
    var tint: Color {
        switch self {
        case .safe(.missing): Palette.inkTertiary
        case .safe: Palette.mint
        case .active: Palette.Vivid.violet
        case .unsaved: Palette.Vivid.orange
        case .blocked(.inUse): Palette.accent
        case .blocked: Palette.inkSecondary
        }
    }

    var symbolName: String {
        switch self {
        case .safe(.missing): "questionmark.folder"
        case .safe: "checkmark.circle.fill"
        case .active: "hammer"
        case .unsaved: "exclamationmark.triangle.fill"
        case .blocked(.inUse): "waveform.path.ecg"
        case .blocked(.locked): "lock.fill"
        case .blocked(.main): "house"
        }
    }

    var shortTitle: String {
        switch self {
        case .safe(.missing): String(localized: "Folder gone")
        case .safe: String(localized: "Safe to remove")
        case .active: String(localized: "In progress")
        case .unsaved: String(localized: "Unsaved work")
        case .blocked(.inUse): String(localized: "In use")
        case .blocked(.locked): String(localized: "Locked")
        case .blocked(.main): String(localized: "Main")
        }
    }

    /// One or two sentences for the inspector: why it's in this state, and what removing it does.
    var explanation: String {
        switch self {
        case .safe(.missing):
            String(localized: "Its folder was deleted, but git still lists it. Removing it only tidies git's records.")
        case .safe(.merged):
            String(localized: "Everything on this branch is already in the default branch, and nothing is uncommitted. Removing it frees the folder; the branch stays.")
        case .safe(.stale(let days)):
            String(localized: "Nobody has committed here in \(days) days and nothing is uncommitted. Removing it frees the folder; the branch and its commits stay.")
        case .active:
            String(localized: "This branch has commits the default branch doesn't, made in the last \(WorktreeSafety.staleDays) days. Removing the folder keeps the branch and its commits.")
        case .unsaved:
            String(localized: "Removing it would lose the work below. Commit or stash it first, or confirm you don't need it.")
        case .blocked(.inUse(let users)):
            String(localized: "\(ListFormatter.localizedString(byJoining: users)) is working in this folder. Quit it there before removing the worktree.")
        case .blocked(.locked):
            String(localized: "Someone locked this worktree so it isn't removed by accident. Unlock it with git worktree unlock to remove it.")
        case .blocked(.main):
            String(localized: "The repository's own folder. Other worktrees branch from it, and it can't be removed as a worktree.")
        }
    }
}

/// The status mark at the end of a row: a symbol and a label in the verdict's colour.
struct WorktreeStatusMark: View {
    let verdict: WorktreeVerdict

    var body: some View {
        Label(verdict.shortTitle, systemImage: verdict.symbolName)
            .labelStyle(StatusLabelStyle())
            .foregroundStyle(verdict.tint)
            .help(verdict.title)
    }

    private struct StatusLabelStyle: LabelStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 4) {
                configuration.icon
                    .font(.system(size: 11, weight: .semibold))
                configuration.title
                    .prose(12, .medium)
            }
        }
    }
}

extension GitWorktree {
    /// "~/Developer/clove/.claude/worktrees/fix-nav"
    var displayPath: String {
        url.path(percentEncoded: false).replacing(URL.homeDirectory.path(percentEncoded: false), with: "~/")
    }

    /// "3 ahead · 12 behind · 2 days ago"
    var graphSummary: String {
        if isMissing { return String(localized: "Folder deleted") }
        var parts: [String] = []
        if !isMain {
            parts.append(ahead == 0 ? String(localized: "nothing new") : String(localized: "\(ahead) ahead"))
            if behind > 0 { parts.append(String(localized: "\(behind) behind")) }
        }
        if let lastCommit {
            parts.append(lastCommit.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)))
        }
        return parts.joined(separator: " · ")
    }
}
