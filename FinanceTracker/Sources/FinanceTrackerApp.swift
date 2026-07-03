import SwiftUI
import SwiftData

@main
struct FinanceTrackerApp: App {
    @AppStorage(AppTheme.storageKey) private var appTheme: String = AppTheme.system.rawValue

    let modelContainer: ModelContainer = {
        let schema = Schema([Transaction.self, Category.self])
        // Local-only storage: no CloudKit sync, all data stays on device.
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            CategorySeeder.seedIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme((AppTheme(rawValue: appTheme) ?? .system).colorScheme)
        }
        .modelContainer(modelContainer)
    }
}
