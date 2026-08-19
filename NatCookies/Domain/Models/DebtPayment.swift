import Foundation

struct DebtPayment: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var amount: Double
}
