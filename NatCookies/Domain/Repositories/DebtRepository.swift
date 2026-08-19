import Foundation
import Combine

protocol DebtRepository {
    var debtsPublisher: AnyPublisher<[Debt], Never> { get }
    func fetchDebts() -> [Debt]
    func saveDebts(_ debts: [Debt])
}
