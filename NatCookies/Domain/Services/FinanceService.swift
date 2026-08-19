import Foundation
import Combine

class FinanceService {
    private let transactionRepository: TransactionRepository
    private let savingsGoalRepository: SavingsGoalRepository
    private let inventoryService: InventoryService
    
    init(
        transactionRepository: TransactionRepository,
        savingsGoalRepository: SavingsGoalRepository,
        inventoryService: InventoryService
    ) {
        self.transactionRepository = transactionRepository
        self.savingsGoalRepository = savingsGoalRepository
        self.inventoryService = inventoryService
    }
    
    var transactionsPublisher: AnyPublisher<[Transaction], Never> {
        transactionRepository.transactionsPublisher
    }
    
    var savingsGoalsPublisher: AnyPublisher<[SavingsGoal], Never> {
        savingsGoalRepository.savingsGoalsPublisher
    }
    
    func getAllTransactions() -> [Transaction] {
        transactionRepository.fetchTransactions()
    }
    
    func getAllSavingsGoals() -> [SavingsGoal] {
        savingsGoalRepository.fetchSavingsGoals()
    }
    
    func addTransaction(
        amount: Double,
        type: TransactionType,
        paymentMethod: PaymentMethod,
        description: String,
        customerName: String? = nil,
        items: [TransactionItem] = [],
        rawCost: Double = 0,
        laborCost: Double = 0,
        profit: Double = 0
    ) {
        var transactions = transactionRepository.fetchTransactions()
        let tx = Transaction(
            amount: amount,
            type: type,
            paymentMethod: paymentMethod,
            description: description,
            customerName: customerName,
            items: items,
            rawCost: rawCost,
            laborCost: laborCost,
            profit: profit
        )
        transactions.insert(tx, at: 0)
        transactionRepository.saveTransactions(transactions)
        
        // If it's a sale, deduct inventory stock
        if type == .sale {
            for item in items {
                inventoryService.deductStock(productId: item.productId, quantity: item.quantity)
            }
        }
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        var transactions = transactionRepository.fetchTransactions()
        for index in offsets {
            let tx = transactions[index]
            // If it was a sale, restore the products stock
            if tx.type == .sale {
                for item in tx.items {
                    inventoryService.increaseStock(productId: item.productId, quantity: item.quantity)
                }
            }
        }
        transactions = transactions.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map { $0.element }
        transactionRepository.saveTransactions(transactions)
    }
    
    func addSavings(goalId: UUID, amount: Double, paymentMethod: PaymentMethod) {
        var goals = savingsGoalRepository.fetchSavingsGoals()
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].currentAmount += amount
            savingsGoalRepository.saveSavingsGoals(goals)
            
            addTransaction(
                amount: amount,
                type: .expense,
                paymentMethod: paymentMethod,
                description: "Depósito Meta: \(goals[index].title)"
            )
        }
    }
    
    func addSavingsGoal(title: String, target: Double, imageName: String) {
        var goals = savingsGoalRepository.fetchSavingsGoals()
        let newGoal = SavingsGoal(title: title, targetAmount: target, currentAmount: 0, imageName: imageName)
        goals.append(newGoal)
        savingsGoalRepository.saveSavingsGoals(goals)
    }
    
    func deleteSavingsGoal(at offsets: IndexSet) {
        var goals = savingsGoalRepository.fetchSavingsGoals()
        goals = goals.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map { $0.element }
        savingsGoalRepository.saveSavingsGoals(goals)
    }
    
    func deleteSavingsGoal(id: UUID) {
        var goals = savingsGoalRepository.fetchSavingsGoals()
        goals.removeAll(where: { $0.id == id })
        savingsGoalRepository.saveSavingsGoals(goals)
    }
}
