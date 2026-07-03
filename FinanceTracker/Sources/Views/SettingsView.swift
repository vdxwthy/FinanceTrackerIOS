import SwiftUI

struct SettingsView: View {
    @AppStorage(CurrencyFormatter.currencyCodeKey) private var currencyCode: String = CurrencyFormatter.currentCode

    var body: some View {
        NavigationStack {
            List {
                Section("settings.currency") {
                    Picker("settings.currency", selection: $currencyCode) {
                        ForEach(SupportedCurrency.codes, id: \.self) { code in
                            Text("\(code) — \(SupportedCurrency.name(for: code))").tag(code)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("settings.categories") {
                    NavigationLink("categories.title") {
                        CategoriesManagementView()
                    }
                }
            }
            .navigationTitle("settings.title")
        }
    }
}

#Preview {
    SettingsView()
}
