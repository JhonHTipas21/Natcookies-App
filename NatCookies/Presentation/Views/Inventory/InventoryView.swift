import SwiftUI

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    let inventoryService: InventoryService
    
    @State private var showingAddProduct = false
    @State private var selectedProductForStockUpdate: Product? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Category Selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(viewModel.categories, id: \.self) { cat in
                                Button(action: { viewModel.selectedCategory = cat }) {
                                    Text(cat)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(viewModel.selectedCategory == cat ? Color.natEspresso : Color.white)
                                        .foregroundColor(viewModel.selectedCategory == cat ? Color.white : Color.natEspresso)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                    
                    // Product List
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if viewModel.filteredProducts.isEmpty {
                                Text("No hay productos en esta categoría.")
                                    .font(.subheadline)
                                    .foregroundColor(.natMutedText)
                                    .padding(.top, 40)
                            } else {
                                ForEach(viewModel.filteredProducts) { product in
                                    HStack(spacing: 16) {
                                        // Product Image Emoji Icon
                                        ZStack {
                                            Circle()
                                                .fill(Color.natPeach.opacity(0.3))
                                                .frame(width: 50, height: 50)
                                            
                                            Text(product.icon)
                                                .font(.title2)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(product.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.natEspresso)
                                            
                                            Text("Mano Obra: $\(Int(product.laborCost).formatted()) • Mat. Prima: $\(Int(product.costPrice).formatted())")
                                                .font(.system(size: 10))
                                                .foregroundColor(.natMutedText)
                                            
                                            Text("Venta: $\(Int(product.sellingPrice).formatted()) (Margen: $\(Int(product.profitPerUnit).formatted()))")
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.natGold)
                                            
                                            if product.stock <= product.alertThreshold {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                        .foregroundColor(.natRose)
                                                        .font(.caption2)
                                                    Text("Stock Bajo")
                                                        .font(.caption2)
                                                        .foregroundColor(.natRose)
                                                        .fontWeight(.bold)
                                                }
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        // Stock counter + Tap to quick edit
                                        Button(action: { selectedProductForStockUpdate = product }) {
                                            VStack(spacing: 2) {
                                                Text("\(product.stock)")
                                                    .font(.title3)
                                                    .fontWeight(.bold)
                                                    .foregroundColor(product.stock <= product.alertThreshold ? .natRose : .natEspresso)
                                                Text("uds")
                                                    .font(.caption2)
                                                    .foregroundColor(.natMutedText)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.natCream)
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(Color.natEspresso.opacity(0.1), lineWidth: 1)
                                            )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Inventario")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddProduct = true }) {
                        Image(systemName: "plus")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.natEspresso)
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingAddProduct) {
                AddProductForm(inventoryService: inventoryService, isPresented: $showingAddProduct)
            }
            .sheet(item: $selectedProductForStockUpdate) { product in
                StockUpdateForm(
                    inventoryService: inventoryService,
                    product: product,
                    isPresented: Binding(
                        get: { selectedProductForStockUpdate != nil },
                        set: { if !$0 { selectedProductForStockUpdate = nil } }
                    )
                )
            }
        }
    }
}
