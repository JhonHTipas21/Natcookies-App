import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    private let financeService: FinanceService
    private let debtService: DebtService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var transactions: [Transaction] = []
    @Published var savingsGoals: [SavingsGoal] = []
    @Published var debts: [Debt] = []
    
    init(financeService: FinanceService, debtService: DebtService) {
        self.financeService = financeService
        self.debtService = debtService
        
        // Reactively sync data
        financeService.transactionsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.transactions, on: self)
            .store(in: &cancellables)
        
        financeService.savingsGoalsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.savingsGoals, on: self)
            .store(in: &cancellables)
        
        debtService.debtsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.debts, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Metrics
    var totalIngresos: Double {
        transactions
            .filter { $0.type == .sale }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var totalGastos: Double {
        transactions
            .filter { $0.type == .expense }
            .map { $0.amount }
            .reduce(0, +)
    }
    
    var totalManoDeObra: Double {
        transactions
            .filter { $0.type == .sale }
            .map { $0.laborCost }
            .reduce(0, +)
    }
    
    var totalMateriaPrima: Double {
        transactions
            .filter { $0.type == .sale }
            .map { $0.rawCost }
            .reduce(0, +)
    }
    
    var gananciaReal: Double {
        max(0, totalIngresos - totalGastos - totalManoDeObra - totalMateriaPrima)
    }
    
    var toReceiveAmount: Double {
        debts
            .filter { $0.type == .toReceive && !$0.isPaid }
            .map { $0.remainingAmount }
            .reduce(0, +)
    }
    
    var firstGoal: SavingsGoal? {
        savingsGoals.first
    }
    
    // MARK: - Weekly Performance Data
    var last7DaysData: [(String, Double)] {
        let calendar = Calendar.current
        let now = Date()
        var list: [(String, Double)] = []
        let daysOfWeek = ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]
        
        for i in (0..<7).reversed() {
            if let dayDate = calendar.date(byAdding: .day, value: -i, to: now) {
                let weekdayIndex = calendar.component(.weekday, from: dayDate) - 1
                let dayLabel = daysOfWeek[weekdayIndex]
                let daySales = transactions
                    .filter { $0.type == .sale && calendar.isDate($0.date, inSameDayAs: dayDate) }
                    .map { $0.amount }
                    .reduce(0, +)
                list.append((dayLabel, daySales))
            }
        }
        return list
    }
}
