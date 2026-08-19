import Foundation
import Combine

class UserDefaultsProductRepository: ProductRepository {
    private let dataStore: UserDefaultsDataStore
    
    init(dataStore: UserDefaultsDataStore = .shared) {
        self.dataStore = dataStore
    }
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        dataStore.productsSubject.eraseToAnyPublisher()
    }
    
    func fetchProducts() -> [Product] {
        dataStore.productsSubject.value
    }
    
    func saveProducts(_ products: [Product]) {
        dataStore.saveProducts(products)
    }
}
