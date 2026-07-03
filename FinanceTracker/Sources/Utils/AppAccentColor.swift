import SwiftUI

enum AppAccentColor: String, CaseIterable {
    case green = "#34B36B"
    case blue = "#339AF0"
    case purple = "#845EF7"
    case pink = "#F06595"
    case orange = "#FF922B"
    case red = "#FF6B6B"
    case teal = "#22B8CF"
    case yellow = "#FFD43B"

    static let storageKey = "accentColorHex"
    static let `default`: AppAccentColor = .green

    var color: Color { Color(hex: rawValue) }
}
