import SwiftUI
import SwiftData

struct CategoryEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let type: TransactionType
    var editingCategory: Category?
    var onSave: ((Category) -> Void)?

    @State private var name: String = ""
    @State private var icon: String = CategoryIcon.all[0]
    @State private var colorHex: String = CategoryColorPalette.all[0]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    private var isBuiltIn: Bool { editingCategory?.isCustom == false }

    private var isValid: Bool {
        isBuiltIn || !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                if !isBuiltIn {
                    Section("categoryEditor.name") {
                        TextField("categoryEditor.namePlaceholder", text: $name)
                    }
                }

                Section("categoryEditor.preview") {
                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 64, height: 64)
                            Image(systemName: icon)
                                .font(.title)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }

                Section("categoryEditor.icon") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CategoryIcon.all, id: \.self) { symbol in
                            Button {
                                icon = symbol
                            } label: {
                                Image(systemName: symbol)
                                    .font(.title3)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle().fill(icon == symbol ? Color(hex: colorHex).opacity(0.2) : Color(.tertiarySystemFill))
                                    )
                                    .foregroundStyle(icon == symbol ? Color(hex: colorHex) : .primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("categoryEditor.color") {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(CategoryColorPalette.all, id: \.self) { hex in
                            Button {
                                colorHex = hex
                            } label: {
                                Circle()
                                    .fill(Color(hex: hex))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.primary, lineWidth: colorHex == hex ? 2 : 0)
                                            .padding(2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle(editingCategory == nil ? "categoryEditor.newTitle" : "categoryEditor.editTitle")
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
            .onAppear(perform: loadExisting)
        }
    }

    private func loadExisting() {
        guard let editingCategory else { return }
        name = editingCategory.customName ?? ""
        icon = editingCategory.icon
        colorHex = editingCategory.colorHex
    }

    private func save() {
        if let editingCategory {
            editingCategory.icon = icon
            editingCategory.colorHex = colorHex
            if editingCategory.isCustom {
                editingCategory.customName = name.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            onSave?(editingCategory)
        } else {
            let newCategory = Category(
                customName: name.trimmingCharacters(in: .whitespacesAndNewlines),
                icon: icon,
                colorHex: colorHex,
                type: type,
                sortOrder: 1000
            )
            modelContext.insert(newCategory)
            onSave?(newCategory)
        }
        dismiss()
    }
}

#Preview {
    CategoryEditorView(type: .expense)
        .modelContainer(for: Category.self, inMemory: true)
}
