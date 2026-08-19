import Foundation
import Combine

class InventoryService {
    private let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    var productsPublisher: AnyPublisher<[Product], Never> {
        productRepository.productsPublisher
    }
    
    func getAllProducts() -> [Product] {
        productRepository.fetchProducts()
    }
    
    func addProduct(name: String, description: String, category: String, costPrice: Double, laborCost: Double, sellingPrice: Double, stock: Int, alertThreshold: Int, icon: String) {
        var products = productRepository.fetchProducts()
        let newProd = Product(
            name: name,
            description: description,
            category: category,
            costPrice: costPrice,
            laborCost: laborCost,
            sellingPrice: sellingPrice,
            stock: stock,
            alertThreshold: alertThreshold,
            icon: icon
        )
        products.append(newProd)
        productRepository.saveProducts(products)
    }
    
    func deleteProduct(at offsets: IndexSet) {
        var products = productRepository.fetchProducts()
        products = products.enumerated()
            .filter { !offsets.contains($0.offset) }
            .map { $0.element }
        productRepository.saveProducts(products)
    }
    
    func deleteProduct(id: UUID) {
        var products = productRepository.fetchProducts()
        products.removeAll(where: { $0.id == id })
        productRepository.saveProducts(products)
    }
    
    func updateProduct(_ product: Product) {
        var products = productRepository.fetchProducts()
        if let index = products.firstIndex(where: { $0.id == product.id }) {
            products[index] = product
            productRepository.saveProducts(products)
        }
    }
    
    func deductStock(productId: UUID, quantity: Int) {
        var products = productRepository.fetchProducts()
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].stock = max(0, products[index].stock - quantity)
            productRepository.saveProducts(products)
        }
    }
    
    func increaseStock(productId: UUID, quantity: Int) {
        var products = productRepository.fetchProducts()
        if let index = products.firstIndex(where: { $0.id == productId }) {
            products[index].stock += quantity
            productRepository.saveProducts(products)
        }
    }
}
