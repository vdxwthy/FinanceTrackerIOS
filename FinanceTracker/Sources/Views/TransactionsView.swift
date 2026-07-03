import SwiftUI
import SwiftData

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var searchText = ""
    @State private var filterType: TransactionType?
    @State private var editingTransaction: Transaction?

    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            let matchesType = filterType == nil || transaction.type == filterType
            let categoryName = transaction.category?.displayName ?? ""
            let matchesSearch = searchText.isEmpty ||
                categoryName.localizedCaseInsensitiveContains(searchText) ||
                transaction.note.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesSearch
        }
    }

    private var groupedByDay: [(date: Date, transactions: [Transaction])] {
        let calendar = Calendar.current
        let groups = Dictionary(grouping: filteredTransactions) { calendar.startOfDay(for: $0.date) }
        return groups
            .map { (date: $0.key, transactions: $0.value) }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredTransactions.isEmpty {
                    ContentUnavailableView(
                        String(localized: "transactions.emptyTitle"),
                        systemImage: "tray",
                        description: Text(searchText.isEmpty
                            ? String(localized: "transactions.emptySubtitle")
                            : String(format: String(localized: "transactions.noResults"), searchText))
                    )
                } else {
                    List {
                        ForEach(groupedByDay, id: \.date) { group in
                            Section(group.date.formatted(date: .abbreviated, time: .omitted)) {
                                ForEach(group.transactions) { transaction in
                                    TransactionRow(transaction: transaction)
                                        .contentShape(Rectangle())
                                        .onTapGesture { editingTransaction = transaction }
                                }
                                .onDelete { offsets in
                                    delete(offsets: offsets, from: group.transactions)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: Text("transactions.searchPrompt"))
            .navigationTitle("tab.transactions")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("transactions.filterAll") { filterType = nil }
                        Button(TransactionType.income.label) { filterType = .income }
                        Button(TransactionType.expense.label) { filterType = .expense }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle\(filterType == nil ? "" : ".fill")")
                    }
                }
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionFormView(transaction: transaction)
            }
        }
    }

    private func delete(offsets: IndexSet, from dayTransactions: [Transaction]) {
        for index in offsets {
            modelContext.delete(dayTransactions[index])
        }
    }
}

#Preview {
    TransactionsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
