import SwiftUI

struct RecordPaymentForm: View {
    let debtService: DebtService
    let debt: Debt
    @Binding var isPresented: Bool
    
    @State private var amountStr = ""
    @State private var selectedMethod: PaymentMethod = .cash
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(debt.customerName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.natEspresso)
                
                VStack(spacing: 4) {
                    Text("Deuda Pendiente Original")
                        .font(.caption)
                        .foregroundColor(.natMutedText)
                    Text("$\(Int(debt.remainingAmount).formatted())")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.natRose)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("Monto a Abonar ($)")
                            .fontWeight(.bold)
                            .foregroundColor(.natEspresso)
                        Spacer()
                        TextField("0", text: $amountStr)
                            .keyboardType(.numberPad)
                            .font(.headline)
                            .multilineTextAlignment(.trailing)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                            )
                            .frame(width: 150)
                    }
                    
                    Picker("Medio de Pago", selection: $selectedMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.top)
            .background(Color.natCream.ignoresSafeArea())
            .navigationBarTitle("Registrar Abono", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Guardar") {
                    if let payment = Double(amountStr), payment > 0 {
                        debtService.addPayment(to: debt.id, amount: payment, method: selectedMethod)
                    }
                    isPresented = false
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
                .disabled(amountStr.isEmpty)
            )
        }
    }
}
