import SwiftUI

struct MedicineDetailView: View {
    @Binding var medicine: Medicine
    @StateObject var viewModel = MedicineStockViewModel()
    @EnvironmentObject var session: SessionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(medicine.name).font(.largeTitle).padding(.top, 20)
                medicineNameSection
                medicineStockSection
                medicineAisleSection
                historySection
            }
            .padding(.vertical)
        }
        .navigationBarTitle("Détails", displayMode: .inline)
        .onAppear { viewModel.fetchHistory(for: medicine) }
    }
}

extension MedicineDetailView {
    private var medicineNameSection: some View {
        VStack(alignment: .leading) {
            Text("Nom").font(.headline)
            TextField("Nom", text: $medicine.name, onCommit: {
                viewModel.updateMedicine(medicine, user: session.session?.email ?? "Inconnu")
            }).textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
    }

    private var medicineStockSection: some View {
        VStack(alignment: .leading) {
            Text("Stock").font(.headline)
            HStack {
                Button(action: {
                    if medicine.stock > 0 {
                        viewModel.decreaseStock(medicine, user: session.session?.email ?? "Inconnu")
                    }
                }) {
                    Image(systemName: "minus.circle").font(.title).foregroundColor(.red)
                }
                .accessibilityLabel("Diminuer le stock")

                TextField("Stock", value: $medicine.stock, formatter: NumberFormatter(), onCommit: {
                    viewModel.updateMedicine(medicine, user: session.session?.email ?? "Inconnu")
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad).frame(width: 80).multilineTextAlignment(.center)

                Button(action: {
                    viewModel.increaseStock(medicine, user: session.session?.email ?? "Inconnu")
                }) {
                    Image(systemName: "plus.circle").font(.title).foregroundColor(.green)
                }
                .accessibilityLabel("Augmenter le stock")
            }
        }.padding(.horizontal)
    }

    private var medicineAisleSection: some View {
        VStack(alignment: .leading) {
            Text("Rayon").font(.headline)
            TextField("Rayon", text: $medicine.aisle, onCommit: {
                viewModel.updateMedicine(medicine, user: session.session?.email ?? "Inconnu")
            }).textFieldStyle(RoundedBorderTextFieldStyle())
        }.padding(.horizontal)
    }

    private var historySection: some View {
        VStack(alignment: .leading) {
            Text("Historique").font(.headline).padding(.top, 10)
            ForEach(viewModel.history.sorted(by: { $0.timestamp > $1.timestamp })) { entry in
                VStack(alignment: .leading) {
                    Text(entry.action).bold()
                    Text("Par : \(entry.user)").font(.caption)
                    Text(entry.timestamp.formatted()).font(.caption2)
                    Text(entry.details).font(.footnote).italic()
                }
                .padding(8).frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground)).cornerRadius(8)
            }
        }.padding(.horizontal)
    }
}
