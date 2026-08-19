import SwiftUI

struct FinancesView: View {
    @ObservedObject var viewModel: FinancesViewModel
    let financeService: FinanceService
    
    // Savings Goal Dialog States
    @State private var showingAddGoal = false
    @State private var newGoalTitle = ""
    @State private var newGoalTarget = ""
    @State private var selectedGoalIcon = "kitchenaid"
    @FocusState private var isInputActive: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // SECTION 1: Isolated Simulator (Simulador de Precios)
                        VStack(alignment: .leading, spacing: 14) {
                            Text("SIMULADOR DE MARGENES")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .tracking(1.5)
                                .foregroundColor(.natGold)
                            
                            Text("Simula precios de forma aislada sin afectar tu inventario real.")
                                .font(.caption)
                                .foregroundColor(.natMutedText)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Costo Materia Prima ($)")
                                        .font(.subheadline)
                                        .foregroundColor(.natEspresso)
                                    Spacer()
                                    TextField("0", text: $viewModel.simRawCost)
                                        .keyboardType(.numberPad)
                                        .focused($isInputActive)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                                
                                HStack {
                                    Text("Mano de Obra ($)")
                                        .font(.subheadline)
                                        .foregroundColor(.natEspresso)
                                    Spacer()
                                    TextField("0", text: $viewModel.simLaborCost)
                                        .keyboardType(.numberPad)
                                        .focused($isInputActive)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                                
                                HStack {
                                    Text("Precio Venta Estimado ($)")
                                        .font(.subheadline)
                                        .foregroundColor(.natEspresso)
                                    Spacer()
                                    TextField("0", text: $viewModel.simSellingPrice)
                                        .keyboardType(.numberPad)
                                        .focused($isInputActive)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                }
                                .padding(.vertical, 4)
                                
                                Divider()
                                    .background(Color.natEspresso.opacity(0.1))
                                
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Ganancia Neta")
                                            .font(.caption2)
                                            .foregroundColor(.natMutedText)
                                        Text("$\(Int(viewModel.simProfit).formatted())")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.natSage)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("Margen Porcentual")
                                            .font(.caption2)
                                            .foregroundColor(.natMutedText)
                                        Text(String(format: "%.1f%%", viewModel.simMargin))
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.natGold)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(18)
                            .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                        }
                        .padding(.horizontal)
                        
                        // SECTION 2: Savings Goals (Metas de Ahorro)
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Text("METAS DE AHORRO")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .tracking(1.5)
                                    .foregroundColor(.natGold)
                                Spacer()
                                Button(action: { showingAddGoal = true }) {
                                    Label("Nueva Meta", systemImage: "plus.circle")
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.natEspresso)
                                }
                            }
                            
                            ForEach(viewModel.savingsGoals) { goal in
                                SavingsGoalRow(
                                    financeService: financeService,
                                    viewModel: viewModel,
                                    goal: goal
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Finanzas & Margen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Listo") {
                        isInputActive = false
                    }
                    .foregroundColor(.natEspresso)
                    .fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingAddGoal) {
                NavigationView {
                    Form {
                        Section(header: Text("Nueva Meta").foregroundColor(.natEspresso)) {
                            TextField("Nombre de la meta (ej: Batidora KitchenAid)", text: $newGoalTitle)
                            TextField("Monto Objetivo ($)", text: $newGoalTarget)
                                .keyboardType(.numberPad)
                            
                            Picker("Icono", selection: $selectedGoalIcon) {
                                Text("KitchenAid").tag("kitchenaid")
                                Text("Horno").tag("oven")
                                Text("Local").tag("store")
                                Text("Inversión").tag("trend")
                            }
                        }
                    }
                    .navigationBarTitle("Agregar Meta", displayMode: .inline)
                    .navigationBarItems(
                        leading: Button("Cancelar") { showingAddGoal = false }
                            .foregroundColor(.natRose),
                        trailing: Button("Guardar") {
                            if let target = Double(newGoalTarget), !newGoalTitle.isEmpty {
                                viewModel.addSavingsGoal(title: newGoalTitle, target: target, imageName: selectedGoalIcon)
                            }
                            showingAddGoal = false
                            newGoalTitle = ""
                            newGoalTarget = ""
                        }
                        .foregroundColor(.natSage)
                        .fontWeight(.bold)
                    )
                }
            }
        }
    }
}

// MARK: - Savings Goal Row Component

struct SavingsGoalRow: View {
    let financeService: FinanceService
    let viewModel: FinancesViewModel
    let goal: SavingsGoal
    @State private var showingDeposit = false
    
    var progress: Double {
        guard goal.targetAmount > 0 else { return 0 }
        return min(1.0, goal.currentAmount / goal.targetAmount)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Goal Icon
                ZStack {
                    Circle()
                        .fill(Color.natPeach.opacity(0.3))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: iconName(goal.imageName))
                        .foregroundColor(.natEspresso)
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.natEspresso)
                    
                    Text("$\(Int(goal.currentAmount).formatted()) / $\(Int(goal.targetAmount).formatted())")
                        .font(.caption)
                        .foregroundColor(.natMutedText)
                }
                Spacer()
                
                HStack(spacing: 8) {
                    Button(action: {
                        viewModel.deleteSavingsGoal(id: goal.id)
                    }) {
                        Image(systemName: "trash")
                            .font(.caption)
                            .foregroundColor(.natRose)
                            .padding(8)
                            .background(Color.natRose.opacity(0.1))
                            .clipShape(Circle())
                    }
                    
                    Button(action: { showingDeposit = true }) {
                        Text("Depositar")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.natSage)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.natCream)
                        .frame(height: 6)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.natGold)
                        .frame(width: geo.size.width * CGFloat(progress), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
        .sheet(isPresented: $showingDeposit) {
            DepositSavingsForm(financeService: financeService, goal: goal, isPresented: $showingDeposit)
        }
    }
    
    private func iconName(_ key: String) -> String {
        switch key {
        case "kitchenaid": return "stove"
        case "oven": return "flame.fill"
        case "store": return "shop.fill"
        default: return "chart.line.uptrend.xyaxis"
        }
    }
}
