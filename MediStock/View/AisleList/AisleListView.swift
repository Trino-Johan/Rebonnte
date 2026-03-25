import SwiftUI

struct AisleListView: View {
    @StateObject var viewModel = MedicineStockViewModel()
    @EnvironmentObject var session: SessionStore
    @State private var showAddSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()
                
                List {
                    ForEach(viewModel.aisles, id: \.self) { aisle in
                        NavigationLink(destination: MedicineListView(viewModel: viewModel, aisle: aisle)) {
                            Text(aisle)
                                .font(.body)
                        }
                        .accessibilityLabel("Rayon \(aisle)")
                        .accessibilityHint("Affiche la liste des médicaments dans ce rayon")
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle("Rayons")
                .navigationBarItems(
                    leading: Button(action: { session.signOut() }) {
                        Text("Déconnexion").foregroundColor(.red)
                    }
                    .accessibilityLabel("Se déconnecter")
                    .accessibilityHint("Ferme votre session actuelle"),
                    
                    trailing: Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                    .accessibilityLabel("Ajouter un médicament")
                )
                
                if viewModel.isLoading {
                    ProgressView().padding().background(Color(.tertiarySystemBackground)).cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddMedicineView(viewModel: viewModel)
        }
        .onAppear { viewModel.fetchAisles() }
    }
}
