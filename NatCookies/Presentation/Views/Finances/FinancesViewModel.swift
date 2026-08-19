import Foundation
import Combine

class FinancesViewModel: ObservableObject {
    private let financeService: FinanceService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var savingsGoals: [SavingsGoal] = []
    
    // Isolated Simulator States
    @Published var simRawCost = ""
    @Published var simLaborCost = ""
    @Published var simSellingPrice = ""
    
    init(financeService: FinanceService) {
        self.financeService = financeService
        
        financeService.savingsGoalsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.savingsGoals, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Simulator Computations
    var simProfit: Double {
        let sell = Double(simSellingPrice) ?? 0.0
        let raw = Double(simRawCost) ?? 0.0
        let labor = Double(simLaborCost) ?? 0.0
        return max(0, sell - raw - labor)
    }
    
    var simMargin: Double {
        let sell = Double(simSellingPrice) ?? 0.0
        guard sell > 0 else { return 0.0 }
        return (simProfit / sell) * 100
    }
    
    // MARK: - Actions
    func addSavingsGoal(title: String, target: Double, imageName: String) {
        financeService.addSavingsGoal(title: title, target: target, imageName: imageName)
    }
    
    func deleteSavingsGoal(id: UUID) {
        financeService.deleteSavingsGoal(id: id)
    }
}
