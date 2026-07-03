import SwiftUI

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var label: String {
        switch self {
        case .income: return String(localized: "type.income")
        case .expense: return String(localized: "type.expense")
        }
    }

    var tintColor: Color {
        switch self {
        case .income: return .green
        case .expense: return .red
        }
    }

    var sign: String {
        switch self {
        case .income: return "+"
        case .expense: return "-"
        }
    }
}
