import Foundation

struct Debt: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var customerName: String
    var customerPhone: String
    var amount: Double
    var type: DebtType
    var date: Date = Date()
    var dueDate: Date = Date()
    var notes: String
    var payments: [DebtPayment] = []
    var isPaid: Bool = false
    
    var remainingAmount: Double {
        let totalPaid = payments.map { $0.amount }.reduce(0, +)
        return max(0, amount - totalPaid)
    }
}
