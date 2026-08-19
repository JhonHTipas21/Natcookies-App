import SwiftUI

struct CatalogView: View {
    @ObservedObject var viewModel: CatalogViewModel
    @State private var showingShareAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.natCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Branding Cover
                        VStack(spacing: 8) {
                            Text("NAT")
                                .font(.system(size: 20, weight: .light, design: .serif))
                                .tracking(6)
                                .foregroundColor(.natEspresso)
                            
                            Text("Cookies")
                                .font(.system(size: 40, weight: .bold, design: .serif))
                                .italic()
                                .foregroundColor(.natEspresso)
                            
                            Text("• ARTESANAL •")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(4)
                                .foregroundColor(.natGold)
                            
                            Text("Galletas estilo NY 🍪")
                                .font(.footnote)
                                .foregroundColor(.natMutedText)
                                .padding(.top, 4)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white)
                                .shadow(color: Color.natEspresso.opacity(0.04), radius: 10, x: 0, y: 4)
                        )
                        .padding(.horizontal)
                        
                        // Menu grid (replicating Instagram "Cookies Menú")
                        VStack(alignment: .leading, spacing: 16) {
                            Text("NUESTRO MENÚ")
                                .font(.system(.subheadline, design: .serif))
                                .fontWeight(.bold)
                                .tracking(2)
                                .foregroundColor(.natEspresso)
                                .padding(.horizontal)
                            
                            ForEach(viewModel.cookiesMenu) { cookie in
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.natPeach.opacity(0.25))
                                            .frame(width: 60, height: 60)
                                        
                                        Text("🍪")
                                            .font(.title)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(cookie.name.uppercased())
                                            .font(.system(.subheadline, design: .serif))
                                            .fontWeight(.bold)
                                            .foregroundColor(.natEspresso)
                                        
                                        Text(cookie.description)
                                            .font(.caption2)
                                            .foregroundColor(.natMutedText)
                                            .lineLimit(2)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(Int(cookie.sellingPrice).formatted())")
                                        .font(.system(.subheadline, design: .serif))
                                        .fontWeight(.black)
                                        .foregroundColor(.natGold)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Dessert tables & Special categories
                        if !viewModel.specialMenu.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("MESAS DULCES Y DETALLES")
                                    .font(.system(.subheadline, design: .serif))
                                    .fontWeight(.bold)
                                    .tracking(2)
                                    .foregroundColor(.natEspresso)
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.specialMenu) { item in
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.natGold.opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Text(item.category == "Detalles" ? "🎁" : "🧁")
                                                .font(.title)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.name)
                                                .font(.system(.subheadline, design: .serif))
                                                .fontWeight(.bold)
                                                .foregroundColor(.natEspresso)
                                            Text(item.description)
                                                .font(.caption2)
                                                .foregroundColor(.natMutedText)
                                                .lineLimit(2)
                                        }
                                        Spacer()
                                        
                                        Text("$\(Int(item.sellingPrice).formatted())")
                                            .font(.system(.subheadline, design: .serif))
                                            .fontWeight(.black)
                                            .foregroundColor(.natGold)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: Color.natEspresso.opacity(0.02), radius: 6, x: 0, y: 3)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Share Action Button
                        Button(action: {
                            showingShareAlert = true
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                Text("Compartir Catálogo Digital")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.natEspresso)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .padding(.horizontal)
                            .shadow(color: Color.natEspresso.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationTitle("Mi Catálogo")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showingShareAlert) {
                Alert(
                    title: Text("Catálogo Compartido"),
                    message: Text("Se ha generado y copiado al portapapeles el enlace de tu catálogo virtual para que lo compartas con tus clientes por WhatsApp o Redes Sociales."),
                    dismissButton: .default(Text("Entendido")) {
                        UIPasteboard.general.string = "https://natcookies.co/catalogo/artesanal"
                    }
                )
            }
        }
    }
}
