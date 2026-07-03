import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    private var icon: String { transaction.category?.icon ?? "questionmark.circle.fill" }
    private var color: Color { transaction.category?.color ?? .gray }
    private var name: String { transaction.category?.displayName ?? String(localized: "category.other") }

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.body)
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(transaction.type.sign)\(CurrencyFormatter.string(from: transaction.amount))")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(transaction.type.tintColor)
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
