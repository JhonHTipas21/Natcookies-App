import Foundation
import Combine

protocol TransactionRepository {
    var transactionsPublisher: AnyPublisher<[Transaction], Never> { get }
    func fetchTransactions() -> [Transaction]
    func saveTransactions(_ transactions: [Transaction])
}
