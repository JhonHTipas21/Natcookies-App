import SwiftUI

struct QuickExpenseForm: View {
    let financeService: FinanceService
    @Binding var isPresented: Bool
    
    @State private var amountStr = ""
    @State private var description = ""
    @State private var method: PaymentMethod = .cash
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Gasto").foregroundColor(.natEspresso)) {
                    HStack {
                        Text("Monto ($)")
                        Spacer()
                        TextField("0", text: $amountStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("Descripción / Concepto (ej: Cajas de regalo, Harina)", text: $description)
                        .foregroundColor(.natEspresso)
                    
                    Picker("Medio de Pago", selection: $method) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
            }
            .navigationBarTitle("Nuevo Gasto 💸", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Guardar Gasto") {
                    saveExpense()
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
                .disabled(amountStr.isEmpty)
            )
        }
    }
    
    private func saveExpense() {
        guard let amount = Double(amountStr), amount > 0 else { return }
        
        financeService.addTransaction(
            amount: amount,
            type: .expense,
            paymentMethod: method,
            description: description.isEmpty ? "Gasto Operativo" : description,
            rawCost: 0,
            laborCost: 0,
            profit: 0
        )
        isPresented = false
    }
}
