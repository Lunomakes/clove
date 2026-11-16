import SwiftUI

struct RunningArt: View {
    var body: some View {
        MockStack {
            MockProcessCard(name: "playwright", detail: "from Claude Code · \(Duration.seconds(720).formatted(.units(allowed: [.minutes], width: .abbreviated)))")
        } middle: {
            MockProcessCard(name: "next dev", detail: "my-app · from Codex", port: ":3000")
        } front: {
            MockProcessCard(name: "Claude Code", detail: "my-app · \(Duration.seconds(7200).formatted(.units(allowed: [.hours], width: .abbreviated))) · \(Int64(410_000_000).formatted(.byteCount(style: .file)))")
        }
    }
}
