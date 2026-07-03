import SwiftUI

struct SettingsView: View {
    @AppStorage(CurrencyFormatter.currencyCodeKey) private var currencyCode: String = CurrencyFormatter.currentCode
    @AppStorage(AppTheme.storageKey) private var appTheme: String = AppTheme.system.rawValue

    var body: some View {
        NavigationStack {
            List {
                Section("settings.appearance") {
                    Picker("settings.theme", selection: $appTheme) {
                        ForEach(AppTheme.allCases, id: \.rawValue) { theme in
                            Text(theme.titleKey).tag(theme.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

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
