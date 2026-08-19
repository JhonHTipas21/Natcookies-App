import SwiftUI

struct QuickSaleForm: View {
    let financeService: FinanceService
    let inventoryService: InventoryService
    @Binding var isPresented: Bool
    
    @State private var customerName = ""
    @State private var paymentMethod: PaymentMethod = .cash
    
    // Quick Item Selection
    @State private var selectedCookieId: UUID? = nil
    @State private var packType: PackType = .individual
    @State private var quantity: Int = 1
    
    // Custom Sales
    @State private var customSales: [CustomSaleItem] = []
    @State private var showCustomSection = false
    @State private var customAmountStr = ""
    @State private var customDesc = ""
    
    enum PackType: String, CaseIterable, Identifiable {
        case individual = "Individual ($6.000)"
        case x2 = "Caja x2 ($13.000)"
        case x3 = "Caja x3 ($18.000)"
        
        var id: String { self.rawValue }
        
        var price: Double {
            switch self {
            case .individual: return 6000
            case .x2: return 13000
            case .x3: return 18000
            }
        }
        
        var qtyMultiplier: Int {
            switch self {
            case .individual: return 1
            case .x2: return 2
            case .x3: return 3
            }
        }
    }
    
    struct CustomSaleItem: Identifiable {
        let id = UUID()
        let name: String
        let price: Double
        let qty: Int
        let rawCost: Double
        let laborCost: Double
    }
    
    // Computed Values
    var currentSubtotal: Double {
        var total = 0.0
        
        // From current selection
        if let cookieId = selectedCookieId, let _ = inventoryService.getAllProducts().first(where: { $0.id == cookieId }) {
            total += packType.price * Double(quantity)
        }
        
        // From custom items
        for item in customSales {
            total += item.price * Double(item.qty)
        }
        
        return total
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("CLIENTE Y PAGO").foregroundColor(.natEspresso)) {
                    TextField("Nombre del Cliente (Opcional)", text: $customerName)
                        .foregroundColor(.natEspresso)
                    
                    Picker("Medio de Pago", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                }
                
                Section(header: Text("SELECCIÓN RÁPIDA DE GALLETAS").foregroundColor(.natEspresso)) {
                    Text("Escoge una galleta y el tipo de empaque:")
                        .font(.caption)
                        .foregroundColor(.natMutedText)
                    
                    // Horizontal selector of cookie flavors
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(inventoryService.getAllProducts().filter { $0.category == "Galletas" }) { cookie in
                                Button(action: {
                                    selectedCookieId = cookie.id
                                }) {
                                    VStack(spacing: 6) {
                                        Text(cookie.icon)
                                            .font(.title)
                                        Text(cookie.name)
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(selectedCookieId == cookie.id ? .white : .natEspresso)
                                    }
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 14)
                                    .background(selectedCookieId == cookie.id ? Color.natEspresso : Color.white)
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    if selectedCookieId != nil {
                        Picker("Empaque / Presentación", selection: $packType) {
                            ForEach(PackType.allCases) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical, 4)
                        
                        Stepper("Cantidad: \(quantity)", value: $quantity, in: 1...100)
                            .foregroundColor(.natEspresso)
                    }
                }
                
                if !customSales.isEmpty {
                    Section(header: Text("ITEMS AGREGADOS").foregroundColor(.natEspresso)) {
                        ForEach(customSales) { item in
                            HStack {
                                Text("\(item.qty)x \(item.name)")
                                Spacer()
                                Text("$\(Int(item.price * Double(item.qty)).formatted())")
                            }
                        }
                        .onDelete(perform: deleteCustomItem)
                    }
                }
                
                Section(header: Text("OTROS PRODUCTOS / VALOR PERSONALIZADO").foregroundColor(.natEspresso)) {
                    if showCustomSection {
                        TextField("Descripción del producto", text: $customDesc)
                        HStack {
                            Text("Valor ($)")
                            Spacer()
                            TextField("0", text: $customAmountStr)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Button(action: addCustomItem) {
                            HStack {
                                Spacer()
                                Image(systemName: "plus.circle.fill")
                                Text("Añadir a la Venta")
                                Spacer()
                            }
                            .foregroundColor(.natSage)
                        }
                    } else {
                        Button(action: { showCustomSection = true }) {
                            Text("+ Registrar otro concepto o producto")
                                .font(.caption)
                                .foregroundColor(.natGold)
                        }
                    }
                }
                
                Section(header: Text("TOTAL DE VENTA").foregroundColor(.natEspresso)) {
                    HStack {
                        Text("Subtotal")
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(Int(currentSubtotal).formatted()) COP")
                            .font(.headline)
                            .foregroundColor(.natSage)
                    }
                }
            }
            .navigationBarTitle("Nueva Venta 🍪", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancelar") { isPresented = false }
                    .foregroundColor(.natRose),
                trailing: Button("Guardar Venta") {
                    saveSale()
                }
                .foregroundColor(.natSage)
                .fontWeight(.bold)
                .disabled(currentSubtotal == 0)
            )
        }
    }
    
    private func addCustomItem() {
        guard let price = Double(customAmountStr), price > 0, !customDesc.isEmpty else { return }
        let newItem = CustomSaleItem(
            name: customDesc,
            price: price,
            qty: 1,
            rawCost: price * 0.3, // Estimar 30% costo
            laborCost: price * 0.15 // Estimar 15% mano de obra
        )
        customSales.append(newItem)
        customDesc = ""
        customAmountStr = ""
        showCustomSection = false
    }
    
    private func deleteCustomItem(at offsets: IndexSet) {
        customSales.remove(atOffsets: offsets)
    }
    
    private func saveSale() {
        var saleItems: [TransactionItem] = []
        var finalDescriptionParts: [String] = []
        
        var totalRawCost = 0.0
        var totalLaborCost = 0.0
        
        // 1. Process current fast selector selection if available
        if let cookieId = selectedCookieId, let cookie = inventoryService.getAllProducts().first(where: { $0.id == cookieId }) {
            let totalQtyOfCookies = packType.qtyMultiplier * quantity
            
            let item = TransactionItem(
                productId: cookie.id,
                productName: "\(cookie.name) (\(packType.rawValue))",
                quantity: quantity,
                price: packType.price
            )
            saleItems.append(item)
            finalDescriptionParts.append("\(quantity)x \(cookie.name) [\(packType == .individual ? "Indiv" : packType == .x2 ? "Caja x2" : "Caja x3")]")
            
            // Financial calculations
            totalRawCost += cookie.costPrice * Double(totalQtyOfCookies)
            totalLaborCost += cookie.laborCost * Double(totalQtyOfCookies)
        }
        
        // 2. Process custom items
        for item in customSales {
            let txItem = TransactionItem(
                productId: UUID(),
                productName: item.name,
                quantity: item.qty,
                price: item.price
            )
            saleItems.append(txItem)
            finalDescriptionParts.append("\(item.qty)x \(item.name)")
            
            totalRawCost += item.rawCost * Double(item.qty)
            totalLaborCost += item.laborCost * Double(item.qty)
        }
        
        let finalAmount = currentSubtotal
        let finalProfit = max(0, finalAmount - totalRawCost - totalLaborCost)
        
        let desc = finalDescriptionParts.joined(separator: ", ")
        
        financeService.addTransaction(
            amount: finalAmount,
            type: .sale,
            paymentMethod: paymentMethod,
            description: desc.isEmpty ? "Venta de Cookies" : desc,
            customerName: customerName.isEmpty ? nil : customerName,
            items: saleItems,
            rawCost: totalRawCost,
            laborCost: totalLaborCost,
            profit: finalProfit
        )
        
        isPresented = false
    }
}
