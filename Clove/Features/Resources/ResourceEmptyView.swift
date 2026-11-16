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
            CalmEmptyState(title: kind.emptyTitle, message: "\(kind.explanation) \(whereToFind)") {
                ResourceArt(kind: kind)
            }
        }
    }

    private var whereToFind: String {
        switch kind {
        case .instructions: String(localized: "Add a CLAUDE.md or AGENTS.md to a project or to ~/.claude.")
        case .rules: String(localized: "Cursor reads them from .cursor/rules in each project.")
        case .commands: String(localized: "Claude Code reads them from ~/.claude/commands, Cursor from ~/.cursor/commands.")
        case .subagents: String(localized: "Claude Code reads them from ~/.claude/agents.")
        case .mcpServers: String(localized: "Add one with claude mcp add, or in Cursor's MCP settings.")
        case .hooks: String(localized: "Claude Code reads them from settings.json, Cursor from hooks.json.")
        case .permissions: String(localized: "Claude Code saves them when you approve a command with “always allow.”")
        }
    }
}
