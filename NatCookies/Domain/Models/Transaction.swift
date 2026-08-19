import Foundation

struct Transaction: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var amount: Double
    var type: TransactionType
    var paymentMethod: PaymentMethod
    var description: String
    var customerId: UUID?
    var customerName: String?
    var items: [TransactionItem] = []
    
    // Financial breakdowns
    var rawCost: Double = 0
    var laborCost: Double = 0
    var profit: Double = 0
}
