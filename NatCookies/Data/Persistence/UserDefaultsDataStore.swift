import Foundation
import Combine

class UserDefaultsDataStore {
    static let shared = UserDefaultsDataStore()
    
    // MARK: - Persistence Keys
    private let transactionsKey = "natcookies_transactions_key"
    private let productsKey = "natcookies_products_key"
    private let debtsKey = "natcookies_debts_key"
    private let savingsGoalsKey = "natcookies_savings_goals_key"
    
    // MARK: - Reactive Subjects
    let productsSubject: CurrentValueSubject<[Product], Never>
    let transactionsSubject: CurrentValueSubject<[Transaction], Never>
    let debtsSubject: CurrentValueSubject<[Debt], Never>
    let savingsGoalsSubject: CurrentValueSubject<[SavingsGoal], Never>
    
    private init() {
        // Load initial data or default empty arrays
        let loadedProducts = UserDefaultsDataStore.load([Product].self, forKey: productsKey) ?? []
        let loadedTransactions = UserDefaultsDataStore.load([Transaction].self, forKey: transactionsKey) ?? []
        let loadedDebts = UserDefaultsDataStore.load([Debt].self, forKey: debtsKey) ?? []
        let loadedSavingsGoals = UserDefaultsDataStore.load([SavingsGoal].self, forKey: savingsGoalsKey) ?? []
        
        self.productsSubject = CurrentValueSubject(loadedProducts)
        self.transactionsSubject = CurrentValueSubject(loadedTransactions)
        self.debtsSubject = CurrentValueSubject(loadedDebts)
        self.savingsGoalsSubject = CurrentValueSubject(loadedSavingsGoals)
        
        // If products are empty, populate initial products as before
        if loadedProducts.isEmpty {
            let initial = UserDefaultsDataStore.loadInitialCleanProducts()
            self.productsSubject.value = initial
            save(initial, forKey: productsKey)
        }
    }
    
    // MARK: - Helper Methods
    func saveProducts(_ products: [Product]) {
        productsSubject.value = products
        save(products, forKey: productsKey)
    }
    
    func saveTransactions(_ transactions: [Transaction]) {
        transactionsSubject.value = transactions
        save(transactions, forKey: transactionsKey)
    }
    
    func saveDebts(_ debts: [Debt]) {
        debtsSubject.value = debts
        save(debts, forKey: debtsKey)
    }
    
    func saveSavingsGoals(_ goals: [SavingsGoal]) {
        savingsGoalsSubject.value = goals
        save(goals, forKey: savingsGoalsKey)
    }
    
    private func save<T: Encodable>(_ value: T, forKey key: String) {
        if let encoded = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private static func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    private static func loadInitialCleanProducts() -> [Product] {
        return [
            Product(name: "Macadamia", description: "Galleta de macadamia tostada y chocolate blanco", category: "Galletas", costPrice: 2000, laborCost: 1000, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Chips Clásica", description: "Galleta clásica de vainilla con chispas de chocolate semi-amargo", category: "Galletas", costPrice: 1800, laborCost: 1000, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Red Velvet", description: "Galleta de terciopelo rojo con chispas de chocolate blanco", category: "Galletas", costPrice: 2200, laborCost: 1200, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Oreo", description: "Galleta artesanal de vainilla con trozos crujientes de galleta Oreo", category: "Galletas", costPrice: 2100, laborCost: 1100, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Maracuyá", description: "Galleta rellena con crema de maracuyá y chocolate blanco", category: "Galletas", costPrice: 2300, laborCost: 1200, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Churro", description: "Galleta de canela y azúcar con centro suave de dulce de leche", category: "Galletas", costPrice: 1900, laborCost: 1000, sellingPrice: 6000, stock: 0, alertThreshold: 5, icon: "🍪"),
            Product(name: "Mesa Dulce (x50)", description: "Arreglo para eventos con 50 mini-galletas decorativas", category: "Mesa dulce", costPrice: 60000, laborCost: 30000, sellingPrice: 180000, stock: 0, alertThreshold: 2, icon: "🧁"),
            Product(name: "Detalle de Regalo", description: "Caja de regalo decorada con cinta de seda", category: "Detalles", costPrice: 8000, laborCost: 4000, sellingPrice: 32000, stock: 0, alertThreshold: 2, icon: "🎁")
        ]
    }
}
