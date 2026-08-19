import Foundation

enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "Efectivo"
    case nequi = "Nequi"
    case daviplata = "Daviplata"
    case bancolombia = "Bancolombia"
}
