import Foundation
import Combine

class UserDefaultsSavingsGoalRepository: SavingsGoalRepository {
    private let dataStore: UserDefaultsDataStore
    
    init(dataStore: UserDefaultsDataStore = .shared) {
        self.dataStore = dataStore
    }
    
    var savingsGoalsPublisher: AnyPublisher<[SavingsGoal], Never> {
        dataStore.savingsGoalsSubject.eraseToAnyPublisher()
    }
    
    func fetchSavingsGoals() -> [SavingsGoal] {
        dataStore.savingsGoalsSubject.value
    }
    
    func saveSavingsGoals(_ goals: [SavingsGoal]) {
        dataStore.saveSavingsGoals(goals)
    }
}
