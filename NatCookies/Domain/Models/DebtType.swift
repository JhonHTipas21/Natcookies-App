import Foundation

enum DebtType: String, Codable, CaseIterable {
    case toReceive = "Por Cobrar (Cliente)"
    case toPay = "Por Pagar (Proveedor)"
}
