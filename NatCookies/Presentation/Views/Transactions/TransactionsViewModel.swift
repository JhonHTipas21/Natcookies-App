import Foundation
import Combine

class TransactionsViewModel: ObservableObject {
    private let financeService: FinanceService
    private var cancellables = Set<AnyCancellable>()
    
    @Published var transactions: [Transaction] = []
    @Published var selectedFilter: TransactionType? = nil
    
    init(financeService: FinanceService) {
        self.financeService = financeService
        
        financeService.transactionsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.transactions, on: self)
            .store(in: &cancellables)
    }
    
    var filteredTransactions: [Transaction] {
        if let filter = selectedFilter {
            return transactions.filter { $0.type == filter }
        }
        return transactions
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        // Map the relative offset in filteredTransactions back to the actual Transaction objects
        let targetTx = filteredTransactions
        let toDeleteIds = offsets.map { targetTx[$0].id }
        
        // Find indices in the full transaction list
        let fullList = financeService.getAllTransactions()
        let indicesToDelete = IndexSet(
            toDeleteIds.compactMap { id in
                fullList.firstIndex(where: { $0.id == id })
            }
        )
        
        financeService.deleteTransaction(at: indicesToDelete)
    }
}
