import Foundation
import Combine

protocol SavingsGoalRepository {
    var savingsGoalsPublisher: AnyPublisher<[SavingsGoal], Never> { get }
    func fetchSavingsGoals() -> [SavingsGoal]
    func saveSavingsGoals(_ goals: [SavingsGoal])
}
