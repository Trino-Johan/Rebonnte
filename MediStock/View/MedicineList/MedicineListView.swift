import SwiftUI

struct MedicineListView: View {
    @ObservedObject var viewModel: MedicineStockViewModel
    @EnvironmentObject var session: SessionStore
    var aisle: String
    
    // Propriété calculée pour filtrer les médicaments par rayon
    private var filteredMedicines: [Medicine] {
        viewModel.medicines.filter { $0.aisle == aisle }
    }
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            List {
                ForEach(filteredMedicines) { medicine in
                    // On retrouve l'index dans la liste principale pour le Binding
                    if let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
                        NavigationLink(destination: MedicineDetailView(medicine: $viewModel.medicines[index], viewModel: viewModel)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(medicine.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Stock disponible : \(medicine.stock)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(medicine.name), stock de \(medicine.stock) unités")
                        }
                    }
                }
                .onDelete(perform: removeRows)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle(aisle, displayMode: .inline)
            
            if viewModel.isLoading {
                ProgressView("Chargement des stocks...")
            }
        }
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
    
    private func removeRows(at offsets: IndexSet) {
        offsets.forEach { index in
            let medicineToDelete = filteredMedicines[index]
            viewModel.deleteMedicine(medicineToDelete, userEmail: session.session?.email ?? "Inconnu")
        }
    }
}
