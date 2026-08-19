import Foundation
import Combine

class DebtService {
    private let debtRepository: DebtRepository
    private let financeService: FinanceService
    
    init(
        debtRepository: DebtRepository,
        financeService: FinanceService
    ) {
        self.debtRepository = debtRepository
        self.financeService = financeService
    }
    
    var debtsPublisher: AnyPublisher<[Debt], Never> {
        debtRepository.debtsPublisher
    }
    
    func getAllDebts() -> [Debt] {
        debtRepository.fetchDebts()
    }
    
    func addDebt(name: String, phone: String, amount: Double, type: DebtType, dueDate: Date, notes: String) {
        var debts = debtRepository.fetchDebts()
        let newDebt = Debt(
            customerName: name,
            customerPhone: phone,
            amount: amount,
            type: type,
            date: Date(),
            dueDate: dueDate,
            notes: notes
        )
        debts.insert(newDebt, at: 0)
        debtRepository.saveDebts(debts)
    }
    
    func deleteDebt(at offsets: IndexSet) {
        var debts = debtRepository.fetchDebts()
        debts = debts.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map { $0.element }
        debtRepository.saveDebts(debts)
    }
    
    func deleteDebt(id: UUID) {
        var debts = debtRepository.fetchDebts()
        debts.removeAll(where: { $0.id == id })
        debtRepository.saveDebts(debts)
    }
    
    func addPayment(to debtId: UUID, amount: Double, method: PaymentMethod) {
        var debts = debtRepository.fetchDebts()
        if let index = debts.firstIndex(where: { $0.id == debtId }) {
            let payment = DebtPayment(date: Date(), amount: amount)
            debts[index].payments.append(payment)
            
            // Check if fully paid
            if debts[index].remainingAmount == 0 {
                debts[index].isPaid = true
            }
            
            // Automatically log a transaction for this payment
            let customer = debts[index].customerName
            let type: TransactionType = debts[index].type == .toReceive ? .sale : .expense
            let desc = debts[index].type == .toReceive ? "Abono de deudor: \(customer)" : "Pago a acreedor: \(customer)"
            
            financeService.addTransaction(
                amount: amount,
                type: type,
                paymentMethod: method,
                description: desc,
                customerName: customer
            )
            
            debtRepository.saveDebts(debts)
        }
    }
}
