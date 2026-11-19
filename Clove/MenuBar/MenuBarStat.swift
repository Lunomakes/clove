import Foundation

/// A number shown next to the menu bar icon, so a glance answers the question
/// without opening anything.
enum MenuBarStat: String, CaseIterable, Identifiable, Sendable {
    case none
    case freeSpace
    case devServers
    case servers
    case containers

    var id: String { rawValue }

    var title: String {
        switch self {
        case .none: String(localized: "Just the icon")
        case .freeSpace: String(localized: "Free space")
        case .devServers: String(localized: "Dev servers running")
        case .servers: String(localized: "All servers running")
        case .containers: String(localized: "Containers running")
        }
    }

    /// How often it's worth checking. Free space barely moves; servers come and go.
    var interval: Duration {
        switch self {
        case .none: .seconds(3600)
        case .freeSpace: .seconds(60)
        case .devServers, .servers, .containers: .seconds(15)
        }
    }

    /// The text beside the icon, and what VoiceOver says. Nil shows the icon alone.
    @MainActor
    func reading(known: [RunningScanner.KnownServer]) async -> (text: String, spoken: String)? {
        switch self {
        case .none:
            return nil
        case .freeSpace:
            guard let volume = StorageVolume.current() else { return nil }
            let free = StorageFormat.capacity(volume.available)
            return (free, String(localized: "\(free) free"))
        case .devServers, .servers:
            let kinds = await RunningScanner.kinds(known: known)
            let count = kinds.filter { self == .devServers ? $0 == .devServer : $0 != .agent }.count
            let spoken: String
            if self == .devServers {
                spoken = count == 0 ? String(localized: "no dev servers running") : String(localized: "\(count) dev servers running")
            } else {
                spoken = count == 0 ? String(localized: "no servers running") : String(localized: "\(count) servers running")
            }
            return (count == 0 ? "" : count.formatted(), spoken)
        case .containers:
            guard case .success(let containers) = await ContainerScanner.list() else { return nil }
            let count = containers.filter(\.state.isRunning).count
            return count == 0 ? ("", String(localized: "no containers running")) : (count.formatted(), String(localized: "\(count) containers running"))
        }
    }
}
