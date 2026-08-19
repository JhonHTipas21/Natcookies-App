import Foundation

struct TransactionItem: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    let productId: UUID
    let productName: String
    let quantity: Int
    let price: Double
}
