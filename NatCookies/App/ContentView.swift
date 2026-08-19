import SwiftUI

struct ContentView: View {
    private let container = DependencyContainer.shared
    
    @StateObject private var dashboardVM: DashboardViewModel
    @StateObject private var transactionsVM: TransactionsViewModel
    @StateObject private var inventoryVM: InventoryViewModel
    @StateObject private var debtsVM: DebtsViewModel
    @StateObject private var financesVM: FinancesViewModel
    
    init() {
        let container = DependencyContainer.shared
        _dashboardVM = StateObject(wrappedValue: container.makeDashboardViewModel())
        _transactionsVM = StateObject(wrappedValue: container.makeTransactionsViewModel())
        _inventoryVM = StateObject(wrappedValue: container.makeInventoryViewModel())
        _debtsVM = StateObject(wrappedValue: container.makeDebtsViewModel())
        _financesVM = StateObject(wrappedValue: container.makeFinancesViewModel())
        
        // Customize UITabBar visual style for premium feel matching brand
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.white)
        
        let activeColor = UIColor(Color.natEspresso)
        let inactiveColor = UIColor(Color.natMutedText.opacity(0.6))
        
        appearance.stackedLayoutAppearance.selected.iconColor = activeColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: activeColor]
        appearance.stackedLayoutAppearance.normal.iconColor = inactiveColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: inactiveColor]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        TabView {
            DashboardView(
                viewModel: dashboardVM,
                financeService: container.financeService,
                inventoryService: container.inventoryService
            )
            .tabItem {
                Label("Inicio", systemImage: "house.fill")
            }
            
            TransactionsView(
                viewModel: transactionsVM,
                financeService: container.financeService,
                inventoryService: container.inventoryService
            )
            .tabItem {
                Label("Flujo Caja", systemImage: "arrow.left.arrow.right.circle.fill")
            }
            
            InventoryView(
                viewModel: inventoryVM,
                inventoryService: container.inventoryService
            )
            .tabItem {
                Label("Inventario", systemImage: "archivebox.fill")
            }
            
            DebtsView(
                viewModel: debtsVM,
                debtService: container.debtService
            )
            .tabItem {
                Label("Fiados", systemImage: "exclamationmark.square.fill")
            }
            
            FinancesView(
                viewModel: financesVM,
                financeService: container.financeService
            )
            .tabItem {
                Label("Finanzas", systemImage: "dollarsign.circle.fill")
            }
        }
        .tint(.natEspresso)
    }
}

#Preview {
    ContentView()
}
