import Foundation

class DependencyContainer {
    static let shared = DependencyContainer()
    
    // Repositories
    let productRepository: ProductRepository
    let transactionRepository: TransactionRepository
    let debtRepository: DebtRepository
    let savingsGoalRepository: SavingsGoalRepository
    
    // Services
    let inventoryService: InventoryService
    let financeService: FinanceService
    let debtService: DebtService
    
    private init() {
        let dataStore = UserDefaultsDataStore.shared
        
        self.productRepository = UserDefaultsProductRepository(dataStore: dataStore)
        self.transactionRepository = UserDefaultsTransactionRepository(dataStore: dataStore)
        self.debtRepository = UserDefaultsDebtRepository(dataStore: dataStore)
        self.savingsGoalRepository = UserDefaultsSavingsGoalRepository(dataStore: dataStore)
        
        self.inventoryService = InventoryService(productRepository: productRepository)
        self.financeService = FinanceService(
            transactionRepository: transactionRepository,
            savingsGoalRepository: savingsGoalRepository,
            inventoryService: inventoryService
        )
        self.debtService = DebtService(
            debtRepository: debtRepository,
            financeService: financeService
        )
    }
    
    // MARK: - ViewModels Factory
    
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(financeService: financeService, debtService: debtService)
    }
    
    func makeTransactionsViewModel() -> TransactionsViewModel {
        TransactionsViewModel(financeService: financeService)
    }
    
    func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(inventoryService: inventoryService)
    }
    
    func makeDebtsViewModel() -> DebtsViewModel {
        DebtsViewModel(debtService: debtService)
    }
    
    func makeFinancesViewModel() -> FinancesViewModel {
        FinancesViewModel(financeService: financeService)
    }
    
    func makeCatalogViewModel() -> CatalogViewModel {
        CatalogViewModel(inventoryService: inventoryService)
    }
}
