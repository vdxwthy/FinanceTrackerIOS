import SwiftUI
import SwiftData

private enum DateFilter: Hashable {
    case all
    case today
    case thisWeek
    case thisMonth
    case custom(start: Date, end: Date)

    var label: String {
        switch self {
        case .all: return String(localized: "transactions.dateFilter.all")
        case .today: return String(localized: "transactions.dateFilter.today")
        case .thisWeek: return String(localized: "transactions.dateFilter.week")
        case .thisMonth: return String(localized: "transactions.dateFilter.month")
        case .custom: return String(localized: "transactions.dateFilter.custom")
        }
    }

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .thisWeek:
            return calendar.isDate(date, equalTo: .now, toGranularity: .weekOfYear)
        case .thisMonth:
            return calendar.isDate(date, equalTo: .now, toGranularity: .month)
        case .custom(let start, let end):
            let startOfDay = calendar.startOfDay(for: start)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: end)) ?? end
            return date >= startOfDay && date < endOfDay
        }
    }
}

struct TransactionsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var searchText = ""
    @State private var filterType: TransactionType?
    @State private var dateFilter: DateFilter = .all
    @State private var isShowingCustomDateSheet = false
    @State private var customStart = Date.now
    @State private var customEnd = Date.now
    @State private var editingTransaction: Transaction?

    private var filteredTransactions: [Transaction] {
        transactions.filter { transaction in
            let matchesType = filterType == nil || transaction.type == filterType
            let matchesDate = dateFilter.contains(transaction.date)
            let categoryName = transaction.category?.displayName ?? ""
            let matchesSearch = searchText.isEmpty ||
                categoryName.localizedCaseInsensitiveContains(searchText) ||
                transaction.note.localizedCaseInsensitiveContains(searchText)
            return matchesType && matchesDate && matchesSearch
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
                                        .swipeActions(edge: .trailing) {
                                            Button(role: .destructive) {
                                                modelContext.delete(transaction)
                                            } label: {
                                                Label("action.delete", systemImage: "trash")
                                            }
                                            Button {
                                                editingTransaction = transaction
                                            } label: {
                                                Label("action.edit", systemImage: "pencil")
                                            }
                                            .tint(.blue)
                                        }
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
                ToolbarItem(placement: .topBarLeading) {
                    Menu {
                        Button("transactions.dateFilter.all") { dateFilter = .all }
                        Button("transactions.dateFilter.today") { dateFilter = .today }
                        Button("transactions.dateFilter.week") { dateFilter = .thisWeek }
                        Button("transactions.dateFilter.month") { dateFilter = .thisMonth }
                        Button("transactions.dateFilter.custom") {
                            customStart = .now
                            customEnd = .now
                            isShowingCustomDateSheet = true
                        }
                    } label: {
                        Image(systemName: dateFilter == .all ? "calendar" : "calendar.badge.checkmark")
                    }
                }
            }
            .sheet(item: $editingTransaction) { transaction in
                TransactionFormView(transaction: transaction)
            }
            .sheet(isPresented: $isShowingCustomDateSheet) {
                NavigationStack {
                    Form {
                        DatePicker("transactions.dateFilter.from", selection: $customStart, displayedComponents: .date)
                        DatePicker("transactions.dateFilter.to", selection: $customEnd, displayedComponents: .date)
                    }
                    .navigationTitle("transactions.dateFilter.custom")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("action.cancel") { isShowingCustomDateSheet = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("action.save") {
                                dateFilter = .custom(start: customStart, end: customEnd)
                                isShowingCustomDateSheet = false
                            }
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

}

#Preview {
    TransactionsView()
        .modelContainer(for: Transaction.self, inMemory: true)
}
