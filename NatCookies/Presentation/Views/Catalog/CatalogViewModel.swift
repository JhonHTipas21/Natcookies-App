import Foundation
import Combine

class CatalogViewModel: ObservableObject {
    private let inventoryService: InventoryService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var products: [Product] = []
    
    init(inventoryService: InventoryService) {
        self.inventoryService = inventoryService
        
        inventoryService.productsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.products, on: self)
            .store(in: &cancellables)
    }
    
    var cookiesMenu: [Product] {
        products.filter { $0.category == "Galletas" }
    }
    
    var specialMenu: [Product] {
        products.filter { $0.category != "Galletas" }
    }
}
