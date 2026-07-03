import SwiftUI
import SwiftData

struct TransactionFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortOrder) private var allCategories: [Category]

    var transaction: Transaction?

    @State private var type: TransactionType = .expense
    @State private var category: Category?
    @State private var amountText: String = ""
    @State private var note: String = ""
    @State private var date: Date = .now
    @State private var isAddingCategory = false

    private var isEditing: Bool { transaction != nil }

    private var categoriesForType: [Category] {
        allCategories.filter { $0.type == type }
    }

    private var isValid: Bool {
        guard let value = Double(amountText.replacingOccurrences(of: ",", with: ".")) else { return false }
        return value > 0 && category != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("form.type", selection: $type) {
                        ForEach(TransactionType.allCases) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: type) { _, newType in
                        if category?.type != newType {
                            category = categoriesForType.first
                        }
                    }
                }

                Section("form.amount") {
                    HStack {
                        Text(CurrencyFormatter.currentSymbol)
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("form.category") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categoriesForType) { cat in
                                CategoryChip(category: cat, isSelected: category?.persistentModelID == cat.persistentModelID) {
                                    category = cat
                                }
                            }
                            Button {
                                isAddingCategory = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                    Text("form.newCategory")
                                        .font(.caption2)
                                }
                                .frame(width: 64)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("form.details") {
                    DatePicker("form.date", selection: $date, displayedComponents: .date)
                    TextField("form.notePlaceholder", text: $note, axis: .vertical)
                }
            }
            .navigationTitle(isEditing ? "form.editTitle" : "form.newTitle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("action.cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("action.save") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear(perform: loadExistingTransaction)
            .sheet(isPresented: $isAddingCategory) {
                CategoryEditorView(type: type) { newCategory in
                    category = newCategory
                }
            }
        }
    }

    private func loadExistingTransaction() {
        guard let transaction else {
            category = categoriesForType.first
            return
        }
        type = transaction.type
        category = transaction.category
        amountText = String(transaction.amount)
        note = transaction.note
        date = transaction.date
    }

    private func save() {
        guard let value = Double(amountText.replacingOccurrences(of: ",", with: ".")), let category else { return }

        if let transaction {
            transaction.amount = value
            transaction.type = type
            transaction.category = category
            transaction.note = note
            transaction.date = date
        } else {
            let newTransaction = Transaction(amount: value, type: type, category: nil, note: note, date: date)
            modelContext.insert(newTransaction)
            newTransaction.category = category
        }

        dismiss()
    }
}

private struct CategoryChip: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(isSelected ? 1 : 0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: category.icon)
                        .foregroundStyle(isSelected ? .white : category.color)
                }
                Text(category.displayName)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .frame(width: 64)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TransactionFormView(transaction: nil)
        .modelContainer(for: Transaction.self, inMemory: true)
}
