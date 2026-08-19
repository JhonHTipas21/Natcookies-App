import SwiftUI

struct AddDebtForm: View {
    let debtService: DebtService
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var phone = ""
    @State private var amountStr = ""
    @State private var type: DebtType = .toReceive
    @State private var dueDate = Date()
    @State private var notes = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Información del Deudor/Acreedor").foregroundColor(.natEspresso)) {
                    TextField("Nombre Completo", text: $name)
                    TextField("Teléfono (ej: +57 300 123 4567)", text: $phone)
                        .keyboardType(.phonePad)
                    
                    Picker("Relación", selection: $type) {
                        Text("Cliente me debe").tag(DebtType.toReceive)
                        Text("Proveedor le debo").tag(DebtType.toPay)
                    }
                }
                
                Section(header: Text("Detalle de Deuda").foregroundColor(.natEspresso)) {
                    HStack {
                        Text("Monto Total ($)")
                        Spacer()
                        TextField("0", text: $amountStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    DatePicker("Fecha de Vencimiento", selection: $dueDate, displayedComponents: .date)
                    
                    TextField("Concepto / Notas (ej: Caja de 6 galletas)", text: $notes)
                }
            }
            .navigationBarTitle("Nueva Deuda", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Guardar") {
                    saveAction()
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
                .disabled(name.isEmpty || amountStr.isEmpty)
            )
        }
    }
    
    private func saveAction() {
        guard !name.isEmpty, let amount = Double(amountStr), amount > 0 else { return }
        debtService.addDebt(
            name: name,
            phone: phone.isEmpty ? "000000" : phone,
            amount: amount,
            type: type,
            dueDate: dueDate,
            notes: notes
        )
        isPresented = false
    }
}
