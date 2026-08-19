import Foundation
import Combine

protocol ProductRepository {
    var productsPublisher: AnyPublisher<[Product], Never> { get }
    func fetchProducts() -> [Product]
    func saveProducts(_ products: [Product])
}
