import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case sale = "Venta"
    case expense = "Gasto"
}
