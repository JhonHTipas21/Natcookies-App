import Foundation
import Combine
import UIKit

class DebtsViewModel: ObservableObject {
    private let debtService: DebtService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var debts: [Debt] = []
    @Published var debtTypeFilter: DebtType = .toReceive
    
    init(debtService: DebtService) {
        self.debtService = debtService
        
        debtService.debtsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.debts, on: self)
            .store(in: &cancellables)
    }
    
    var filteredDebts: [Debt] {
        debts.filter { $0.type == debtTypeFilter && !$0.isPaid }
    }
    
    var totalRemainingDebt: Double {
        filteredDebts.map { $0.remainingAmount }.reduce(0, +)
    }
    
    func deleteDebt(id: UUID) {
        debtService.deleteDebt(id: id)
    }
    
    func sendWhatsAppReminder(debt: Debt) {
        let cleanPhone = debt.customerPhone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "+", with: "")
        
        let message = "Hola \(debt.customerName), espero estés súper bien. Te escribo de NatCookies para recordarte amablemente tu saldo pendiente de $\(Int(debt.remainingAmount).formatted()). ¡Que tengas un lindo día! 🍪✨"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        let urlString = "https://api.whatsapp.com/send?phone=\(cleanPhone)&text=\(encodedMessage)"
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}
