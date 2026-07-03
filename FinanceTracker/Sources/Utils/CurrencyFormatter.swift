import Foundation

enum CurrencyFormatter {
    static let currencyCodeKey = "currencyCode"

    static var currentCode: String {
        UserDefaults.standard.string(forKey: currencyCodeKey) ?? Locale.current.currency?.identifier ?? "USD"
    }

    static func string(from amount: Double) -> String {
        amount.formatted(.currency(code: currentCode))
    }

    static var currentSymbol: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currentCode
        return formatter.currencySymbol ?? currentCode
    }
}

enum SupportedCurrency {
    static let codes: [String] = [
        "USD", "EUR", "RUB", "GBP", "JPY", "CNY", "CHF", "CAD", "AUD",
        "KZT", "UAH", "BYN", "TRY", "INR", "BRL", "AED", "PLN", "SEK", "NOK"
    ]

    static func name(for code: String) -> String {
        Locale.current.localizedString(forCurrencyCode: code) ?? code
    }
}
