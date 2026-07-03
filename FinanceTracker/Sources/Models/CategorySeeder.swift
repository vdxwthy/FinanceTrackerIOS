import SwiftData

enum CategorySeeder {
    private struct Seed {
        let key: String
        let icon: String
        let colorHex: String
        let type: TransactionType
    }

    private static let seeds: [Seed] = [
        Seed(key: "food", icon: "fork.knife", colorHex: "#FF922B", type: .expense),
        Seed(key: "transport", icon: "car.fill", colorHex: "#339AF0", type: .expense),
        Seed(key: "shopping", icon: "bag.fill", colorHex: "#F06595", type: .expense),
        Seed(key: "entertainment", icon: "gamecontroller.fill", colorHex: "#845EF7", type: .expense),
        Seed(key: "health", icon: "cross.case.fill", colorHex: "#FF6B6B", type: .expense),
        Seed(key: "housing", icon: "house.fill", colorHex: "#A9744F", type: .expense),
        Seed(key: "utilities", icon: "bolt.fill", colorHex: "#FFD43B", type: .expense),
        Seed(key: "education", icon: "book.fill", colorHex: "#5C7CFA", type: .expense),
        Seed(key: "travel", icon: "airplane", colorHex: "#22B8CF", type: .expense),
        Seed(key: "otherExpense", icon: "ellipsis.circle.fill", colorHex: "#868E96", type: .expense),
        Seed(key: "salary", icon: "banknote.fill", colorHex: "#37B24D", type: .income),
        Seed(key: "business", icon: "briefcase.fill", colorHex: "#20C997", type: .income),
        Seed(key: "gift", icon: "gift.fill", colorHex: "#F06595", type: .income),
        Seed(key: "investment", icon: "chart.line.uptrend.xyaxis", colorHex: "#1098AD", type: .income),
        Seed(key: "otherIncome", icon: "ellipsis.circle.fill", colorHex: "#868E96", type: .income)
    ]

    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Category>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0
        guard existingCount == 0 else { return }

        for (index, seed) in seeds.enumerated() {
            let category = Category(
                key: seed.key,
                icon: seed.icon,
                colorHex: seed.colorHex,
                type: seed.type,
                sortOrder: index
            )
            context.insert(category)
        }

        try? context.save()
    }
}
