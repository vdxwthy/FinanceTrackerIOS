import SwiftUI
import SwiftData

@Model
final class Category {
    var key: String?
    var customName: String?
    var icon: String
    var colorHex: String
    var typeRaw: String
    var sortOrder: Int

    init(
        key: String? = nil,
        customName: String? = nil,
        icon: String,
        colorHex: String,
        type: TransactionType,
        sortOrder: Int = 0
    ) {
        self.key = key
        self.customName = customName
        self.icon = icon
        self.colorHex = colorHex
        self.typeRaw = type.rawValue
        self.sortOrder = sortOrder
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var color: Color {
        get { Color(hex: colorHex) }
        set { colorHex = newValue.hexString }
    }

    var isCustom: Bool { key == nil }

    var displayName: String {
        if let key {
            return NSLocalizedString("category.\(key)", bundle: .main, comment: "")
        }
        return customName ?? String(localized: "category.other")
    }
}

enum CategoryIcon {
    static let all: [String] = [
        "fork.knife", "cup.and.saucer.fill", "car.fill", "bus.fill", "fuelpump.fill",
        "bag.fill", "cart.fill", "gamecontroller.fill", "film.fill", "music.note",
        "cross.case.fill", "pills.fill", "house.fill", "bolt.fill", "wifi",
        "book.fill", "graduationcap.fill", "airplane", "tram.fill", "figure.walk",
        "pawprint.fill", "gift.fill", "banknote.fill", "briefcase.fill",
        "chart.line.uptrend.xyaxis", "creditcard.fill", "wrench.and.screwdriver.fill",
        "hammer.fill", "leaf.fill", "heart.fill", "dumbbell.fill", "tshirt.fill",
        "scissors", "paintbrush.fill", "camera.fill", "phone.fill", "tv.fill",
        "sofa.fill", "bed.double.fill", "shower.fill", "washer.fill",
        "ellipsis.circle.fill", "star.fill", "tag.fill", "ticket.fill",
        "cake.fill", "birthday.cake.fill", "party.popper.fill", "sportscourt.fill"
    ]
}

enum CategoryColorPalette {
    static let all: [String] = [
        "#FF6B6B", "#FF922B", "#FFD43B", "#94D82D", "#20C997",
        "#22B8CF", "#339AF0", "#5C7CFA", "#845EF7", "#CC5DE8",
        "#F06595", "#868E96", "#A9744F", "#37B24D", "#1098AD"
    ]
}
