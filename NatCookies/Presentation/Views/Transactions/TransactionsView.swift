import SwiftUI

struct TransactionsView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    let financeService: FinanceService
    let inventoryService: InventoryService
    
    @State private var showingAddForm = false
    @State private var formType: TransactionType = .sale
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Filter Bar
                    HStack(spacing: 12) {
                        FilterButton(title: "Todos", isSelected: viewModel.selectedFilter == nil) {
                            viewModel.selectedFilter = nil
                        }
                        FilterButton(title: "Ventas", isSelected: viewModel.selectedFilter == .sale) {
                            viewModel.selectedFilter = .sale
                        }
                        FilterButton(title: "Gastos", isSelected: viewModel.selectedFilter == .expense) {
                            viewModel.selectedFilter = .expense
                        }
                    }
                    .padding()
                    
                    // Transaction List
                    if viewModel.filteredTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle.portrait")
                                .font(.system(size: 48))
                                .foregroundColor(.natPeach)
                            Text("No se encontraron movimientos")
                                .font(.headline)
                                .foregroundColor(.natEspresso)
                            Text("Comienza registrando tus ventas o gastos diarios.")
                                .font(.caption)
                                .foregroundColor(.natMutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete(perform: viewModel.deleteTransaction)
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Caja de Flujo")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            formType = .sale
                            showingAddForm = true
                        }) {
                            Label("Nueva Venta", systemImage: "plus.circle.fill")
                        }
                        
                        Button(action: {
                            formType = .expense
                            showingAddForm = true
                        }) {
                            Label("Nuevo Gasto", systemImage: "minus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.natEspresso)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddForm) {
                if formType == .sale {
                    QuickSaleForm(
                        financeService: financeService,
                        inventoryService: inventoryService,
                        isPresented: $showingAddForm
                    )
                } else {
                    QuickExpenseForm(
                        financeService: financeService,
                        isPresented: $showingAddForm
                    )
                }
            }
        }
    }
}

// MARK: - Filter Button

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.bold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.natEspresso : Color.white)
                .foregroundColor(isSelected ? Color.white : Color.natEspresso)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: Color.natEspresso.opacity(isSelected ? 0.1 : 0), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Transaction Row

struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(transaction.type == .sale ? Color.natSage.opacity(0.15) : Color.natRose.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.type == .sale ? "arrow.down.left" : "arrow.up.right")
                    .foregroundColor(transaction.type == .sale ? .natSage : .natRose)
                    .fontWeight(.bold)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.description)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.natEspresso)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(transaction.paymentMethod.rawValue)
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.natPeach.opacity(0.4))
                        .foregroundColor(.natEspresso)
                        .cornerRadius(6)
                    
                    if let customer = transaction.customerName {
                        Text(customer)
                            .font(.caption2)
                            .foregroundColor(.natMutedText)
                    }
                    
                    Spacer()
                    
                    Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundColor(.natMutedText)
                }
            }
            
            Spacer()
            
            Text((transaction.type == .sale ? "+" : "-") + "$\(Int(transaction.amount).formatted())")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(transaction.type == .sale ? .natSage : .natRose)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.natEspresso.opacity(0.03), radius: 6, x: 0, y: 3)
    }
}
