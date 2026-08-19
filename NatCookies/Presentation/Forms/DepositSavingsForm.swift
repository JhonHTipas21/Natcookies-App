import SwiftUI

struct DepositSavingsForm: View {
    let financeService: FinanceService
    let goal: SavingsGoal
    @Binding var isPresented: Bool
    
    @State private var amountStr = ""
    @State private var method: PaymentMethod = .cash
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Monto a Depositar").foregroundColor(.natEspresso)) {
                    HStack {
                        Text("Monto ($)")
                        Spacer()
                        TextField("0", text: $amountStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Medio de Pago", selection: $method) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
            }
            .navigationBarTitle("Agregar Ahorro", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Depositar") {
                    if let val = Double(amountStr), val > 0 {
                        financeService.addSavings(goalId: goal.id, amount: val, paymentMethod: method)
                    }
                    isPresented = false
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
            )
        }
    }
}
