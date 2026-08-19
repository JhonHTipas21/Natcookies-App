import Foundation
import Combine

class UserDefaultsTransactionRepository: TransactionRepository {
    private let dataStore: UserDefaultsDataStore
    
    init(dataStore: UserDefaultsDataStore = .shared) {
        self.dataStore = dataStore
    }
    
    var transactionsPublisher: AnyPublisher<[Transaction], Never> {
        dataStore.transactionsSubject.eraseToAnyPublisher()
    }
    
    func fetchTransactions() -> [Transaction] {
        dataStore.transactionsSubject.value
    }
    
    func saveTransactions(_ transactions: [Transaction]) {
        dataStore.saveTransactions(transactions)
    }
}
