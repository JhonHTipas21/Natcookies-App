import Foundation

struct SavingsGoal: Codable, Identifiable, Equatable {
    var id: UUID = UUID()
    var title: String
    var targetAmount: Double
    var currentAmount: Double
    var imageName: String
}
