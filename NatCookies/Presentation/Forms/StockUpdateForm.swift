import SwiftUI

struct StockUpdateForm: View {
    let inventoryService: InventoryService
    let product: Product
    @Binding var isPresented: Bool
    
    @State private var adjustmentStr = ""
    @State private var isIncrement = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(product.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.natEspresso)
                
                HStack(spacing: 20) {
                    VStack {
                        Text("Stock Actual")
                            .font(.caption)
                            .foregroundColor(.natMutedText)
                        Text("\(product.stock)")
                            .font(.system(size: 40))
                            .fontWeight(.black)
                            .foregroundColor(.natEspresso)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.natPeach.opacity(0.2))
                    .cornerRadius(16)
                    
                    VStack {
                        Text("Nuevo Stock")
                            .font(.caption)
                            .foregroundColor(.natMutedText)
                        let change = (Int(adjustmentStr) ?? 0) * (isIncrement ? 1 : -1)
                        Text("\(max(0, product.stock + change))")
                            .font(.system(size: 40))
                            .fontWeight(.black)
                            .foregroundColor(.natSage)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.natSage.opacity(0.15))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Picker("Acción", selection: $isIncrement) {
                    Text("Agregar Stock").tag(true)
                    Text("Reducir Stock").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                TextField("Cantidad", text: $adjustmentStr)
                    .keyboardType(.numberPad)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                Button(action: {
                    inventoryService.deleteProduct(id: product.id)
                    isPresented = false
                }) {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Eliminar Producto")
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.natRose)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top)
            .background(Color.natCream.ignoresSafeArea())
            .navigationBarTitle("Ajustar Stock", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Actualizar") {
                    let change = (Int(adjustmentStr) ?? 0) * (isIncrement ? 1 : -1)
                    var updated = product
                    updated.stock = max(0, product.stock + change)
                    inventoryService.updateProduct(updated)
                    isPresented = false
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
            )
        }
    }
}
