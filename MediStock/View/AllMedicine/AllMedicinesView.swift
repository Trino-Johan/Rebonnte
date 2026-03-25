import SwiftUI

struct AllMedicinesView: View {
    @StateObject var viewModel = MedicineStockViewModel()
    @EnvironmentObject var session: SessionStore
    @State private var filterText: String = ""
    @State private var showAddSheet = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // couleur de fond sémantique pour tout l'écran
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Section de recherche optimisée pour le Dark Mode
                    searchBarSection
                    
                    // Liste des Médicaments
                    List {
                        ForEach(filteredMedicines) { medicine in
                            if let index = viewModel.medicines.firstIndex(where: { $0.id == medicine.id }) {
                                NavigationLink(destination: MedicineDetailView(medicine: $viewModel.medicines[index], viewModel: viewModel)) {
                                    medicineRow(medicine: medicine)
                                }
                            }
                        }
                        .onDelete(perform: removeRows)
                    }
                    .listStyle(InsetGroupedListStyle()) // Style natif iOS
                }
                .navigationBarTitle("All Medicines")
                .navigationBarItems(trailing: addButton)
                
                // Indicateur de chargement adaptatif
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .sheet(isPresented: $showAddSheet) {
            AddMedicineView(viewModel: viewModel)
        }
        .onAppear {
            viewModel.fetchMedicines()
        }
    }
}

// MARK: - Subviews & Logic
extension AllMedicinesView {
    
    private var searchBarSection: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            TextField("Rechercher par nom...", text: $filterText)
                .textFieldStyle(PlainTextFieldStyle())
        }
        .padding(10)
        .background(Color(.secondarySystemBackground)) // Couleur adaptative
        .cornerRadius(10)
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private func medicineRow(medicine: Medicine) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(medicine.name)
                .font(.headline)
                .foregroundColor(.primary) // Blanc en mode sombre, noir en mode clair
            Text("Stock: \(medicine.stock)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var addButton: some View {
        Button(action: { showAddSheet = true }) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
        }
        .accessibilityLabel("Ajouter un médicament")
    }
    
    private var loadingOverlay: some View {
        ProgressView("Chargement...")
            .padding()
            .background(Color(.tertiarySystemBackground)) // Fond contrasté en mode sombre
            .cornerRadius(12)
            .shadow(radius: 10)
    }
    
    var filteredMedicines: [Medicine] {
        if filterText.isEmpty {
            return viewModel.medicines
        } else {
            return viewModel.medicines.filter {
                $0.name.lowercased().contains(filterText.lowercased())
            }
        }
    }
    
    private func removeRows(at offsets: IndexSet) {
        offsets.forEach { index in
            let medicineToDelete = filteredMedicines[index]
            viewModel.deleteMedicine(medicineToDelete, userEmail: session.session?.email ?? "Inconnu")
        }
    }
}
