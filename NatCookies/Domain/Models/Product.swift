import Foundation

struct Product: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var description: String
    var category: String
    var costPrice: Double // Costo de materia prima
    var laborCost: Double // Mano de obra
    var sellingPrice: Double // Precio de venta
    var stock: Int
    var alertThreshold: Int
    var icon: String // E.g., emoji like 🍪
    
    var profitPerUnit: Double {
        return max(0, sellingPrice - costPrice - laborCost)
    }
}
