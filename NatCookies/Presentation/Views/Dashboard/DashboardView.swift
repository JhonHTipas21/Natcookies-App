import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel
    let financeService: FinanceService
    let inventoryService: InventoryService
    
    @State private var showingQuickSale = false
    @State private var showingQuickExpense = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("NatCookies")
                                    .font(.system(.title2, design: .serif))
                                    .fontWeight(.bold)
                                    .foregroundColor(.natEspresso)
                                Text("Repostería Artesanal")
                                    .font(.subheadline)
                                    .foregroundColor(.natMutedText)
                            }
                            Spacer()
                            
                            Text("🍪")
                                .font(.title)
                                .padding(8)
                                .background(Color.natPeach.opacity(0.4))
                                .clipShape(Circle())
                        }
                        .padding(.horizontal)
                        
                        // Premium Financial Board
                        VStack(spacing: 16) {
                            Text("Ganancia Neta Disponible")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .fontWeight(.bold)
                                .tracking(1)
                            
                            Text("$\(Int(viewModel.gananciaReal).formatted()) COP")
                                .font(.system(size: 32, weight: .black, design: .serif))
                                .foregroundColor(.white)
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                            
                            // 4-Column detailed breakdown
                            Grid(horizontalSpacing: 10, verticalSpacing: 12) {
                                GridRow {
                                    FinancialMiniCard(title: "Ingresos", amount: viewModel.totalIngresos, color: .white)
                                    FinancialMiniCard(title: "Gastos", amount: viewModel.totalGastos, color: .white.opacity(0.8))
                                }
                                GridRow {
                                    FinancialMiniCard(title: "Mano de Obra", amount: viewModel.totalManoDeObra, color: .natPeach)
                                    FinancialMiniCard(title: "Reinversión", amount: viewModel.totalMateriaPrima, color: .natPeach)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [Color.natEspresso, Color(red: 90/255, green: 60/255, blue: 45/255)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(24)
                        .shadow(color: Color.natEspresso.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Quick Action Buttons
                        HStack(spacing: 16) {
                            Button(action: { showingQuickSale = true }) {
                                HStack {
                                    Image(systemName: "cart.fill.badge.plus")
                                    Text("Registrar Venta")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.natSage)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                            
                            Button(action: { showingQuickExpense = true }) {
                                HStack {
                                    Image(systemName: "minus.circle.fill")
                                    Text("Nuevo Gasto")
                                }
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.natRose)
                                .foregroundColor(.white)
                                .cornerRadius(14)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Savings Goals Banner
                        if let firstGoal = viewModel.firstGoal {
                            SavingsGoalBanner(financeService: financeService, goal: firstGoal)
                                .padding(.horizontal)
                        }
                        
                        // Weekly chart
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Rendimiento Semanal")
                                .font(.headline)
                                .foregroundColor(.natEspresso)
                                .padding(.horizontal)
                            
                            WeeklyMiniChart(data: viewModel.last7DaysData)
                                .frame(height: 120)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(18)
                                .shadow(color: Color.natEspresso.opacity(0.04), radius: 6, x: 0, y: 3)
                                .padding(.horizontal)
                        }
                        
                        // Recent Transactions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Actividad Reciente")
                                .font(.headline)
                                .foregroundColor(.natEspresso)
                            
                            if viewModel.transactions.isEmpty {
                                Text("No hay registros en la caja.")
                                    .font(.subheadline)
                                    .foregroundColor(.natMutedText)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                ForEach(viewModel.transactions.prefix(3)) { transaction in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(transaction.description)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.natEspresso)
                                            Text(transaction.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption2)
                                                .foregroundColor(.natMutedText)
                                        }
                                        Spacer()
                                        Text((transaction.type == .sale ? "+" : "-") + "$\(Int(transaction.amount).formatted())")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(transaction.type == .sale ? .natSage : .natRose)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(14)
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingQuickSale) {
                QuickSaleForm(
                    financeService: financeService,
                    inventoryService: inventoryService,
                    isPresented: $showingQuickSale
                )
            }
            .sheet(isPresented: $showingQuickExpense) {
                QuickExpenseForm(
                    financeService: financeService,
                    isPresented: $showingQuickExpense
                )
            }
        }
    }
}

// MARK: - Components (Private or Internal to Dashboard)

struct FinancialMiniCard: View {
    let title: String
    let amount: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))
                .fontWeight(.bold)
            Text("$\(Int(amount).formatted())")
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color.white.opacity(0.08))
        .cornerRadius(10)
    }
}

struct WeeklyMiniChart: View {
    let data: [(String, Double)]
    
    var body: some View {
        let maxVal = data.map { $0.1 }.max() ?? 1.0
        let displayMax = maxVal == 0 ? 1.0 : maxVal
        
        HStack(alignment: .bottom, spacing: 14) {
            ForEach(data, id: \.0) { item in
                VStack(spacing: 8) {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(item.1 > 0 ? Color.natGold : Color.natPeach.opacity(0.3))
                        .frame(width: 22, height: CGFloat((item.1 / displayMax) * 80))
                        .animation(.spring(), value: item.1)
                    
                    Text(item.0)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.natMutedText)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

struct SavingsGoalBanner: View {
    let financeService: FinanceService
    let goal: SavingsGoal
    @State private var showingDeposit = false
    
    var progress: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(1.0, goal.currentAmount / goal.targetAmount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("META DE AHORRO")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .tracking(1.5)
                        .foregroundColor(.natGold)
                    
                    Text(goal.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundColor(.natEspresso)
                }
                Spacer()
                
                Button(action: { showingDeposit = true }) {
                    Text("Ahorrar")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.natEspresso)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            
            // Progress Bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.natPeach.opacity(0.3))
                            .frame(height: 10)
                        
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.natSage)
                            .frame(width: geo.size.width * CGFloat(progress), height: 10)
                    }
                }
                .frame(height: 10)
                
                HStack {
                    Text("$\(Int(goal.currentAmount).formatted()) ahorrado")
                        .font(.caption2)
                        .foregroundColor(.natMutedText)
                    Spacer()
                    Text("Meta: $\(Int(goal.targetAmount).formatted())")
                        .font(.caption2)
                        .foregroundColor(.natMutedText)
                        .fontWeight(.bold)
                }
            }
        }
        .padding()
        .background(
            ZStack {
                Color.white
                LinearGradient(
                    colors: [Color.natPeach.opacity(0.08), Color.white],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .cornerRadius(18)
        .shadow(color: Color.natEspresso.opacity(0.03), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showingDeposit) {
            DepositSavingsForm(financeService: financeService, goal: goal, isPresented: $showingDeposit)
        }
    }
}
