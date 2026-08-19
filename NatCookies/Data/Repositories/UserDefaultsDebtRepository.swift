import Foundation
import Combine

class UserDefaultsDebtRepository: DebtRepository {
    private let dataStore: UserDefaultsDataStore
    
    init(dataStore: UserDefaultsDataStore = .shared) {
        self.dataStore = dataStore
    }
    
    var debtsPublisher: AnyPublisher<[Debt], Never> {
        dataStore.debtsSubject.eraseToAnyPublisher()
    }
    
    func fetchDebts() -> [Debt] {
        dataStore.debtsSubject.value
    }
    
    func saveDebts(_ debts: [Debt]) {
        dataStore.saveDebts(debts)
    }
}
