import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Double
    var typeRaw: String
    var note: String
    var date: Date
    var createdAt: Date

    @Relationship(deleteRule: .nullify)
    var category: Category?

    init(
        amount: Double,
        type: TransactionType,
        category: Category?,
        note: String = "",
        date: Date = .now
    ) {
        self.amount = amount
        self.typeRaw = type.rawValue
        self.category = category
        self.note = note
        self.date = date
        self.createdAt = .now
    }

    var type: TransactionType {
        get { TransactionType(rawValue: typeRaw) ?? .expense }
        set { typeRaw = newValue.rawValue }
    }

    var signedAmount: Double {
        type == .income ? amount : -amount
    }
}
