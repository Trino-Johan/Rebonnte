import SwiftUI

struct AddMedicineView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    
    @State private var name = ""
    @State private var stock = 0
    @State private var selectedAisleChoice = ""
    @State private var customAisleName = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Nom du médicament", text: $name)
                        .accessibilityLabel("Nom du nouveau médicament")
                    
                    Stepper("Stock initial : \(stock)", value: $stock, in: 0...999)
                        .accessibilityValue("\(stock) unités")
                }
                
                Section(header: Text("Localisation")) {
                    Picker("Rayon", selection: $selectedAisleChoice) {
                        Text("Choisir un rayon...").tag("")
                        ForEach(viewModel.aisles, id: \.self) { aisleName in
                            Text(aisleName).tag(aisleName)
                        }
                        Text("Nouveau rayon...").tag("new_mode")
                    }
                    .accessibilityLabel("Sélection du rayon")

                    if selectedAisleChoice == "new_mode" || viewModel.aisles.isEmpty {
                        TextField("Nom du nouveau rayon", text: $customAisleName)
                            .accessibilityLabel("Entrez le nom du nouveau rayon")
                    }
                }
            }
            .navigationTitle("Nouveau Produit")
            .onAppear {
                viewModel.fetchAisles()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        Task {
                            let finalAisle = (selectedAisleChoice == "new_mode" || viewModel.aisles.isEmpty)
                                            ? customAisleName
                                            : selectedAisleChoice
                            
                            await viewModel.addMedicine(
                                name: name,
                                stock: stock,
                                aisle: finalAisle,
                                userEmail: session.session?.email ?? "Inconnu"
                            )
                            dismiss()
                        }
                    }
                    // La validation vérifie que le nom final n'est pas vide
                    .disabled(name.isEmpty || (selectedAisleChoice == "new_mode" && customAisleName.isEmpty) || (selectedAisleChoice.isEmpty && !viewModel.aisles.isEmpty))
                }
            }
        }
    }
}
