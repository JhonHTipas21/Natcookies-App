import SwiftUI

struct DebtsView: View {
    @ObservedObject var viewModel: DebtsViewModel
    let debtService: DebtService
    
    @State private var showingAddDebt = false
    @State private var selectedDebtForPayment: Debt? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Type picker
                    Picker("Tipo de Deuda", selection: $viewModel.debtTypeFilter) {
                        Text("Me Deben (Clientes)").tag(DebtType.toReceive)
                        Text("Debo (Proveedores)").tag(DebtType.toPay)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Sum card
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.debtTypeFilter == .toReceive ? "Total por Cobrar" : "Total por Pagar")
                                .font(.caption)
                                .foregroundColor(.natMutedText)
                            Text("$\(Int(viewModel.totalRemainingDebt).formatted())")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.natEspresso)
                        }
                        Spacer()
                        Image(systemName: viewModel.debtTypeFilter == .toReceive ? "arrow.down.forward.and.arrow.up.backward" : "arrow.up.forward.and.arrow.down.backward")
                            .font(.title)
                            .foregroundColor(.natGold)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                    .padding(.horizontal)
                    
                    // List of debts
                    if viewModel.filteredDebts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 48))
                                .foregroundColor(.natSage)
                            Text("¡Todo al día!")
                                .font(.headline)
                                .foregroundColor(.natEspresso)
                            Text(viewModel.debtTypeFilter == .toReceive ? "No tienes cuentas pendientes por cobrar." : "No tienes deudas pendientes con proveedores.")
                                .font(.caption)
                                .foregroundColor(.natMutedText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 60)
                        .padding(.horizontal)
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.filteredDebts) { debt in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(debt.customerName)
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.natEspresso)
                                        
                                        if !debt.notes.isEmpty {
                                            Text(debt.notes)
                                                .font(.caption)
                                                .foregroundColor(.natMutedText)
                                                .lineLimit(1)
                                        }
                                        
                                        Text("Vence: \(debt.dueDate.formatted(date: .abbreviated, time: .omitted))")
                                            .font(.caption2)
                                            .foregroundColor(.natRose)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text("$\(Int(debt.remainingAmount).formatted())")
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.natEspresso)
                                        
                                        HStack(spacing: 8) {
                                            if debt.type == .toReceive {
                                                Button(action: {
                                                    viewModel.sendWhatsAppReminder(debt: debt)
                                                }) {
                                                    Image(systemName: "message.fill")
                                                        .font(.caption)
                                                        .foregroundColor(.white)
                                                        .padding(6)
                                                        .background(Color.natSage)
                                                        .clipShape(Circle())
                                                }
                                            }
                                            
                                            Button(action: { selectedDebtForPayment = debt }) {
                                                Text("Abonar")
                                                    .font(.caption2)
                                                    .fontWeight(.bold)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.natGold)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                            }
                            .onDelete { offsets in
                                for index in offsets {
                                    let debt = viewModel.filteredDebts[index]
                                    viewModel.deleteDebt(id: debt.id)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .background(Color.clear)
                    }
                }
            }
            .navigationTitle("Deudas y Fiados")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddDebt = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.natEspresso)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddDebt) {
                AddDebtForm(debtService: debtService, isPresented: $showingAddDebt)
            }
            .sheet(item: $selectedDebtForPayment) { debt in
                RecordPaymentForm(
                    debtService: debtService,
                    debt: debt,
                    isPresented: Binding(
                        get: { selectedDebtForPayment != nil },
                        set: { if !$0 { selectedDebtForPayment = nil } }
                    )
                )
            }
        }
    }
}
