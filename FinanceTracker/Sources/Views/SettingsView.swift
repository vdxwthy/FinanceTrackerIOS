import SwiftUI

struct SettingsView: View {
    @AppStorage(CurrencyFormatter.currencyCodeKey) private var currencyCode: String = CurrencyFormatter.currentCode
    @AppStorage(AppTheme.storageKey) private var appTheme: String = AppTheme.system.rawValue
    @AppStorage(AppAccentColor.storageKey) private var accentColorHex: String = AppAccentColor.default.rawValue

    private let accentColorColumns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

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

                    LazyVGrid(columns: accentColorColumns, spacing: 12) {
                        ForEach(AppAccentColor.allCases, id: \.rawValue) { option in
                            Button {
                                accentColorHex = option.rawValue
                            } label: {
                                Circle()
                                    .fill(option.color)
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(.primary, lineWidth: accentColorHex == option.rawValue ? 2 : 0)
                                            .padding(2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
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
