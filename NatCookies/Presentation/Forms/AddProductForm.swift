import SwiftUI

struct AddProductForm: View {
    let inventoryService: InventoryService
    @Binding var isPresented: Bool
    
    @State private var name = ""
    @State private var description = ""
    @State private var category = "Galletas"
    @State private var costPriceStr = ""
    @State private var laborCostStr = ""
    @State private var sellingPriceStr = ""
    @State private var stockStr = ""
    @State private var alertThresholdStr = "5"
    @State private var selectedIcon = "🍪"
    
    let categoriesList = ["Galletas", "Mesa dulce", "Detalles", "Especiales"]
    let iconsList = ["🍪", "🧁", "🎁", "🍰", "📦", "🥤", "🍩", "🍞"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Detalles del Producto").foregroundColor(.natEspresso)) {
                    TextField("Nombre del Producto", text: $name)
                    TextField("Descripción", text: $description)
                    Picker("Categoría", selection: $category) {
                        ForEach(categoriesList, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    
                    Picker("Icono Representativo", selection: $selectedIcon) {
                        ForEach(iconsList, id: \.self) { icon in
                            Text(icon).tag(icon)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Precios e Inventario").foregroundColor(.natEspresso)) {
                    HStack {
                        Text("Costo de Materia Prima ($)")
                        Spacer()
                        TextField("0", text: $costPriceStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Costo de Mano de Obra ($)")
                        Spacer()
                        TextField("0", text: $laborCostStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Precio de Venta ($)")
                        Spacer()
                        TextField("0", text: $sellingPriceStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Stock Inicial")
                        Spacer()
                        TextField("0", text: $stockStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Alerta de Stock Mínimo")
                        Spacer()
                        TextField("5", text: $alertThresholdStr)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationBarTitle("Agregar Producto", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Guardar") {
                    saveAction()
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
                .disabled(name.isEmpty)
            )
        }
    }
    
    private func saveAction() {
        guard !name.isEmpty else { return }
        let cost = Double(costPriceStr) ?? 0.0
        let labor = Double(laborCostStr) ?? 0.0
        let sell = Double(sellingPriceStr) ?? 0.0
        let stock = Int(stockStr) ?? 0
        let alert = Int(alertThresholdStr) ?? 5
        
        inventoryService.addProduct(
            name: name,
            description: description,
            category: category,
            costPrice: cost,
            laborCost: labor,
            sellingPrice: sell,
            stock: stock,
            alertThreshold: alert,
            icon: selectedIcon
        )
        isPresented = false
    }
}
