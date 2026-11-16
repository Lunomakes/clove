import Foundation

/// Everything besides skills that changes how an agent behaves.
enum ResourceKind: String, CaseIterable, Identifiable, Hashable, Sendable, Codable {
    case instructions
    case rules
    case commands
    case subagents
    case mcpServers
    case hooks
    case permissions

    var id: String { rawValue }

    /// What shapes what an agent knows, and what shapes what it can do.
    static let contextKinds: [ResourceKind] = [.instructions, .rules, .commands, .subagents]
    static let toolKinds: [ResourceKind] = [.mcpServers, .hooks, .permissions]

    var title: String {
        switch self {
        case .instructions: String(localized: "Instructions")
        case .rules: String(localized: "Rules")
        case .commands: String(localized: "Slash Commands")
        case .subagents: String(localized: "Subagents")
        case .mcpServers: String(localized: "MCP Servers")
        case .hooks: String(localized: "Hooks")
        case .permissions: String(localized: "Permissions")
        }
    }

    /// Short enough to fit under the window title.
    var subtitle: String {
        switch self {
        case .instructions: String(localized: "CLAUDE.md, AGENTS.md, and GEMINI.md")
        case .rules: String(localized: "Cursor, Windsurf, and Copilot rules")
        case .commands: String(localized: "Saved prompts you run with /")
        case .subagents: String(localized: "Specialists your agent hands work to")
        case .mcpServers: String(localized: "Extra tools your agents can call")
        case .hooks: String(localized: "Scripts that run on agent events")
        case .permissions: String(localized: "What runs without asking you")
        }
    }

    var emptyTitle: LocalizedStringResource {
        switch self {
        case .instructions: "No instructions yet"
        case .rules: "No rules yet"
        case .commands: "No slash commands yet"
        case .subagents: "No subagents yet"
        case .mcpServers: "No mcp servers yet"
        case .hooks: "No hooks yet"
        case .permissions: "No permissions yet"
        }
    }

    var singular: String {
        switch self {
        case .instructions: String(localized: "instruction file")
        case .rules: String(localized: "rule")
        case .commands: String(localized: "slash command")
        case .subagents: String(localized: "subagent")
        case .mcpServers: String(localized: "MCP server")
        case .hooks: String(localized: "hook")
        case .permissions: String(localized: "permission")
        }
    }

    var symbolName: String {
        switch self {
        case .instructions: "text.document"
        case .rules: "list.bullet.rectangle"
        case .commands: "slash.circle"
        case .subagents: "person.2"
        case .mcpServers: "server.rack"
        case .hooks: "bolt"
        case .permissions: "checkmark.shield"
        }
    }

    /// Whole messages let each language choose sentence spacing and punctuation.
    var emptyMessage: LocalizedStringResource {
        switch self {
        case .instructions: "Notes your agents read at the start of every session, like how to run tests or which patterns to follow. Add a CLAUDE.md or AGENTS.md to a project or to ~/.claude."
        case .rules: "Guidance an agent follows always, for certain files, or when it decides the rule is relevant. Cursor reads them from .cursor/rules in each project."
        case .commands: "Prompts you save once and run with a slash, like /review or /release-notes. Claude Code reads them from ~/.claude/commands, Cursor from ~/.cursor/commands."
        case .subagents: "Focused agents the main agent can hand a task to, like a code reviewer or a test writer. Claude Code reads them from ~/.claude/agents."
        case .mcpServers: "Servers that give agents extra tools, like a browser, Figma, GitHub, or your database. Add one with claude mcp add, or in Cursor's MCP settings."
        case .hooks: "Commands that run on their own before or after an agent acts, like formatting a file after every edit. Claude Code reads them from settings.json, Cursor from hooks.json."
        case .permissions: "Commands and tools an agent may run without stopping to ask you first. Claude Code saves them when you approve a command with “always allow.”"
        }
    }

    var searchPrompt: LocalizedStringResource {
        switch self {
        case .instructions: "Search instructions"
        case .rules: "Search rules"
        case .commands: "Search slash commands"
        case .subagents: "Search subagents"
        case .mcpServers: "Search mcp servers"
        case .hooks: "Search hooks"
        case .permissions: "Search permissions"
        }
    }

    /// Kinds whose text sits in the agent's context in every session.
    var loadsIntoContext: Bool {
        switch self {
        case .instructions, .commands, .subagents: true
        case .rules, .mcpServers, .hooks, .permissions: false
        }
    }
}
