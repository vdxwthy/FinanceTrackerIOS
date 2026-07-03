import SwiftUI
import SwiftData
import Charts

private struct CategorySlice: Identifiable {
    let category: Category?
    let total: Double
    var id: String { category?.persistentModelID.hashValue.description ?? "uncategorized" }
    var name: String { category?.displayName ?? String(localized: "category.other") }
    var color: Color { category?.color ?? .gray }
}

private struct MonthTotal: Identifiable {
    let month: Date
    let type: TransactionType
    let total: Double
    var id: String { "\(month.timeIntervalSince1970)-\(type.rawValue)" }
}

struct StatsView: View {
    @Query private var transactions: [Transaction]

    @State private var selectedType: TransactionType = .expense

    private var breakdownForSelectedType: [CategorySlice] {
        let calendar = Calendar.current
        let now = Date.now
        let filtered = transactions.filter {
            $0.type == selectedType &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .year)
        }
        let grouped = Dictionary(grouping: filtered, by: \.category)
        return grouped
            .map { CategorySlice(category: $0.key, total: $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.total > $1.total }
    }

    private var totalForSelectedType: Double {
        breakdownForSelectedType.reduce(0) { $0 + $1.total }
    }

    private var last6MonthsTotals: [MonthTotal] {
        let calendar = Calendar.current
        let now = Date.now
        var results: [MonthTotal] = []
        for offset in stride(from: 5, through: 0, by: -1) {
            guard let monthDate = calendar.date(byAdding: .month, value: -offset, to: now) else { continue }
            let monthTransactions = transactions.filter {
                calendar.isDate($0.date, equalTo: monthDate, toGranularity: .month) &&
                calendar.isDate($0.date, equalTo: monthDate, toGranularity: .year)
            }
            let income = monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
            let expense = monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
            results.append(MonthTotal(month: monthDate, type: .income, total: income))
            results.append(MonthTotal(month: monthDate, type: .expense, total: expense))
        }
        return results
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Picker("form.type", selection: $selectedType) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    categoryBreakdownSection
                    trendSection
                }
                .padding()
            }
            .navigationTitle("tab.stats")
        }
    }

    @ViewBuilder
    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats.byCategory")
                .font(.headline)

            if breakdownForSelectedType.isEmpty {
                ContentUnavailableView(
                    String(localized: "stats.noData"),
                    systemImage: "chart.pie",
                    description: Text(String(format: String(localized: "stats.noDataDescription"), selectedType.label.lowercased()))
                )
                .frame(height: 200)
            } else {
                Chart(breakdownForSelectedType) { slice in
                    SectorMark(
                        angle: .value("Amount", slice.total),
                        innerRadius: .ratio(0.6),
                        angularInset: 1.5
                    )
                    .foregroundStyle(slice.color)
                    .cornerRadius(4)
                }
                .frame(height: 220)

                VStack(spacing: 0) {
                    ForEach(breakdownForSelectedType) { slice in
                        HStack {
                            Circle().fill(slice.color).frame(width: 10, height: 10)
                            Text(slice.name)
                            Spacer()
                            Text(CurrencyFormatter.string(from: slice.total))
                                .foregroundStyle(.secondary)
                            Text(totalForSelectedType > 0 ? "\(Int(round(slice.total / totalForSelectedType * 100)))%" : "0%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, alignment: .trailing)
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
        }
    }

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("stats.last6Months")
                .font(.headline)

            Chart(last6MonthsTotals) { entry in
                BarMark(
                    x: .value("Month", entry.month, unit: .month),
                    y: .value("Amount", entry.total)
                )
                .foregroundStyle(by: .value("Type", entry.type.label))
                .position(by: .value("Type", entry.type.label))
            }
            .chartForegroundStyleScale([
                TransactionType.income.label: Color.green,
                TransactionType.expense.label: Color.red
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month(.abbreviated))
                }
            }
            .frame(height: 220)
        }
    }
}

#Preview {
    StatsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
