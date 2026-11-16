import Foundation
import Testing
@testable import Clove

struct AppLanguageTests {
    @Test func mapsLanguageCodes() {
        let cases: [(String?, AppLanguage)] = [
            (nil, .system), ("", .system), ("fr", .system), ("zh", .system),
            ("english", .system), ("en", .english), ("en-GB", .english),
            ("zh-Hans", .simplifiedChinese), ("zh-Hans-CN", .simplifiedChinese),
            ("zh-Hant", .traditionalChinese), ("zh-Hant-TW", .traditionalChinese),
            ("zh-TW", .traditionalChinese), ("zh-HK", .traditionalChinese),
            ("zh-CN", .simplifiedChinese), ("zh-MO", .traditionalChinese),
        ]
        for (code, expected) in cases {
            #expect(AppLanguage(languageCode: code) == expected)
        }
    }

    @MainActor @Test func persistsLanguageAndKeepsLaunchSelection() throws {
        let domainName = "clove.language-tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domainName))
        defer { defaults.removePersistentDomain(forName: domainName) }
        let settings = SettingsStore(defaults: defaults, domainName: domainName)
        #expect(settings.language == .system)
        #expect(settings.languageAtLaunch == .system)

        for language in AppLanguage.allCases where language != .system {
            settings.language = language
            #expect(defaults.persistentDomain(forName: domainName)?["AppleLanguages"] as? [String] == [language.rawValue])
            #expect(SettingsStore(defaults: defaults, domainName: domainName).language == language)
            #expect(settings.languageAtLaunch == .system)
        }

        settings.language = .system
        #expect(defaults.persistentDomain(forName: domainName)?["AppleLanguages"] == nil)
        #expect(SettingsStore(defaults: defaults, domainName: domainName).language == .system)

        defaults.set(["zh-TW", "en"], forKey: "AppleLanguages")
        let traditional = SettingsStore(defaults: defaults, domainName: domainName)
        #expect(traditional.language == .traditionalChinese)
        #expect(traditional.languageAtLaunch == .traditionalChinese)
        traditional.language = .english
        #expect(traditional.languageAtLaunch == .traditionalChinese)
        traditional.language = .traditionalChinese
        #expect(traditional.language == traditional.languageAtLaunch)
    }

    @MainActor @Test func ignoresGlobalAndArgumentLanguages() throws {
        let domainName = "clove.language-tests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: domainName))
        defer { defaults.removePersistentDomain(forName: domainName) }

        // Supply a fallback if the Mac has no persisted global language list.
        defaults.setVolatileDomain(["AppleLanguages": ["en"]], forName: UserDefaults.globalDomain)
        #expect(defaults.stringArray(forKey: "AppleLanguages")?.isEmpty == false)
        #expect(defaults.persistentDomain(forName: domainName)?["AppleLanguages"] == nil)
        #expect(SettingsStore(defaults: defaults, domainName: domainName).language == .system)

        defaults.setVolatileDomain(["AppleLanguages": ["zh-Hans"]], forName: UserDefaults.argumentDomain)
        #expect(defaults.stringArray(forKey: "AppleLanguages") == ["zh-Hans"])
        #expect(SettingsStore(defaults: defaults, domainName: domainName).language == .system)

        defaults.set(["zh-TW"], forKey: "AppleLanguages")
        #expect(SettingsStore(defaults: defaults, domainName: domainName).language == .traditionalChinese)
    }
}
