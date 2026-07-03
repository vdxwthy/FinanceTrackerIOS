import SwiftUI

struct RootTabView: View {
    @State private var isAddingTransaction = false

    var body: some View {
        TabView {
            DashboardView(isAddingTransaction: $isAddingTransaction)
                .tabItem { Label("tab.overview", systemImage: "house.fill") }

            TransactionsView()
                .tabItem { Label("tab.transactions", systemImage: "list.bullet") }

            StatsView()
                .tabItem { Label("tab.stats", systemImage: "chart.pie.fill") }

            SettingsView()
                .tabItem { Label("tab.settings", systemImage: "gearshape.fill") }
        }
        .sheet(isPresented: $isAddingTransaction) {
            TransactionFormView(transaction: nil)
        }
    }
}

#Preview {
    RootTabView()
}
