import SwiftUI
import SwiftData

struct CategoriesManagementView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.sortOrder) private var allCategories: [Category]

    @State private var editingCategory: Category?
    @State private var addingType: TransactionType?

    private func categories(for type: TransactionType) -> [Category] {
        allCategories.filter { $0.type == type }
    }

    var body: some View {
        List {
            section(for: .expense)
            section(for: .income)
        }
        .navigationTitle("categories.title")
        .sheet(item: $editingCategory) { category in
            CategoryEditorView(type: category.type, editingCategory: category)
        }
        .sheet(item: $addingType) { type in
            CategoryEditorView(type: type)
        }
    }

    private func section(for type: TransactionType) -> some View {
        Section(type.label) {
            ForEach(categories(for: type)) { category in
                Button {
                    editingCategory = category
                } label: {
                    HStack {
                        ZStack {
                            Circle().fill(category.color.opacity(0.15)).frame(width: 32, height: 32)
                            Image(systemName: category.icon).foregroundStyle(category.color).font(.subheadline)
                        }
                        Text(category.displayName)
                            .foregroundStyle(.primary)
                        Spacer()
                        if !category.isCustom {
                            Image(systemName: "lock.fill")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .swipeActions(edge: .trailing) {
                    if category.isCustom {
                        Button(role: .destructive) {
                            modelContext.delete(category)
                        } label: {
                            Label("action.delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                }
            }

            Button {
                addingType = type
            } label: {
                Label("categories.add", systemImage: "plus.circle.fill")
            }
        }
    }

}

#Preview {
    NavigationStack {
        CategoriesManagementView()
    }
    .modelContainer(for: Category.self, inMemory: true)
}
