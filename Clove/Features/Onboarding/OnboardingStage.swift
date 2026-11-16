import SwiftUI

/// The right half of the guide: a still scene of what the step is about.
struct OnboardingStage: View {
    let step: OnboardingStep

    var body: some View {
        ZStack {
            Palette.surfaceMuted

            scene
                .scaleEffect(1.4)
                .id(step)
                .arrives()
        }
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(Palette.hairline)
                .frame(width: 0.5)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var scene: some View {
        switch step {
        case .welcome:
            SkillsArt()
        case .license:
            MockStack(height: 230) {
                MockFileCard(fileName: "CLAUDE.md", agent: ("Claude Code", .orange), lines: ["## Conventions", "Use SwiftUI and Swift 6."])
            } middle: {
                MockKeyCard(name: "OPENAI_API_KEY")
            } front: {
                MockSkillCard(reference: "/swiftui-pro", summary: "Reviews SwiftUI for modern APIs and accessibility.", badges: [("Claude Code", .orange), ("Codex", .green)])
            }
        case .permissions:
            MockStack {
                MockFileCard(fileName: "~/Downloads", agent: (String(localized: "Storage"), .orange), lines: ["Xcode.xip", "node_modules/"])
            } middle: {
                MockSkillCard(reference: "/nextjs", summary: "Dragged into a prompt.", badges: [(String(localized: "Drag"), .gray)])
            } front: {
                MockSkillCard(reference: "/swiftui-pro", summary: "Typed into your prompt when you press Return.", badges: [(String(localized: "Insert"), Palette.accent)])
            }
        case .shortcut:
            MockStack {
                MockSkillCard(reference: "/review", summary: "Pinned beside your editor.", badges: [(String(localized: "Panel"), .gray)])
            } middle: {
                MockSkillCard(reference: "/animations", summary: "Return types it into your prompt.", badges: [(String(localized: "Panel"), .gray)])
            } front: {
                MockShortcutCard(keys: ["⌃", "⌥", "Space"], caption: "Opens the panel from any app")
            }
        case .ready:
            RunningArt()
        }
    }
}
