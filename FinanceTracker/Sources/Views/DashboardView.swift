import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var isAddingTransaction: Bool

    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    private var currentMonthTransactions: [Transaction] {
        let calendar = Calendar.current
        let now = Date.now
        return transactions.filter {
            calendar.isDate($0.date, equalTo: now, toGranularity: .month) &&
            calendar.isDate($0.date, equalTo: now, toGranularity: .year)
        }
    }

    private var monthIncome: Double {
        currentMonthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var monthExpense: Double {
        currentMonthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var totalBalance: Double {
        transactions.reduce(0) { $0 + $1.signedAmount }
    }

    private var recentTransactions: [Transaction] {
        Array(transactions.prefix(5))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    balanceCard
                    monthSummaryCard

                    if !recentTransactions.isEmpty {
                        recentTransactionsSection
                    } else {
                        emptyState
                    }
                }
                .padding()
            }
            .navigationTitle("tab.overview")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingTransaction = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 8) {
            Text("dashboard.totalBalance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(CurrencyFormatter.string(from: totalBalance))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(totalBalance >= 0 ? Color.primary : Color.red)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color(.secondarySystemBackground)))
    }

    private var monthSummaryCard: some View {
        HStack(spacing: 16) {
            summaryTile(title: TransactionType.income.label, amount: monthIncome, color: .green, icon: "arrow.down.circle.fill")
            summaryTile(title: TransactionType.expense.label, amount: monthExpense, color: .red, icon: "arrow.up.circle.fill")
        }
    }

    private func summaryTile(title: String, amount: Double, color: Color, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(CurrencyFormatter.string(from: amount))
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("dashboard.recent")
                .font(.headline)
            VStack(spacing: 0) {
                ForEach(recentTransactions) { transaction in
                    TransactionRow(transaction: transaction)
                    if transaction.id != recentTransactions.last?.id {
                        Divider()
                    }
                }
            }
            .padding(.horizontal)
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("dashboard.empty")
                .foregroundStyle(.secondary)
            Button("dashboard.addFirst") {
                isAddingTransaction = true
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

#Preview {
    DashboardView(isAddingTransaction: .constant(false))
        .modelContainer(for: Transaction.self, inMemory: true)
}
