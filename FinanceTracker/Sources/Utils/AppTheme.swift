import SwiftUI

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    static let storageKey = "appTheme"

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var titleKey: LocalizedStringKey {
        switch self {
        case .system: return "settings.theme.system"
        case .light: return "settings.theme.light"
        case .dark: return "settings.theme.dark"
        }
    }
}
