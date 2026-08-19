import Foundation
import Combine

class InventoryViewModel: ObservableObject {
    private let inventoryService: InventoryService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products: [Product] = []
    @Published var selectedCategory = "Todos"
    
    init(inventoryService: InventoryService) {
        self.inventoryService = inventoryService
        
        inventoryService.productsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.products, on: self)
            .store(in: &cancellables)
    }
    
    var categories: [String] {
        ["Todos"] + Array(Set(products.map { $0.category })).sorted()
    }
    
    var filteredProducts: [Product] {
        if selectedCategory == "Todos" {
            return products
        }
        return products.filter { $0.category == selectedCategory }
    }
    
    func deleteProduct(id: UUID) {
        inventoryService.deleteProduct(id: id)
    }
    
    func updateProduct(_ product: Product) {
        inventoryService.updateProduct(product)
    }
}
