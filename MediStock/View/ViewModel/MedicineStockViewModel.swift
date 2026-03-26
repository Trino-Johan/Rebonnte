import Foundation
import Firebase

class MedicineStockViewModel: ObservableObject {
    @Published var medicines: [Medicine] = []
    @Published var aisles: [String] = []
    @Published var history: [HistoryEntry] = []
    @Published var isLoading: Bool = false
    
    private var db = Firestore.firestore()
    
    func fetchMedicines() {
        self.isLoading = true
        
        db.collection("medicines").order(by: "name").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    self.medicines = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Medicine.self)
                    } ?? []
                }
            }
        }
    }
    
    func fetchAisles() {
        db.collection("medicines").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error getting aisles: \(error)")
            } else {
                let allMedicines = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Medicine.self)
                } ?? []
                let result = Array(Set(allMedicines.map { $0.aisle })).sorted()
                DispatchQueue.main.async { self.aisles = result }
            }
        }
    }
    
    func addMedicine(name: String, stock: Int, aisle: String, userEmail: String) async {
        let medicine = Medicine(name: name, stock: stock, aisle: aisle)
        do {
            let docRef = try db.collection("medicines").addDocument(from: medicine)
            self.addHistory(
                action: "Création",
                user: userEmail,
                medicineId: docRef.documentID,
                details: "Ajout initial : \(name) (Rayon: \(aisle), Stock: \(stock))"
            )
        } catch {
            print("Erreur lors de l'ajout : \(error.localizedDescription)")
        }
    }
    
    func deleteMedicine(_ medicine: Medicine, userEmail: String) {
        guard let id = medicine.id else { return }
        // Ajout de [weak self] pour la suppression
        db.collection("medicines").document(id).delete { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("Erreur suppression : \(error.localizedDescription)")
            } else {
                self.addHistory(action: "Suppression", user: userEmail, medicineId: id, details: "Suppression de \(medicine.name)")
            }
        }
    }
    
    func increaseStock(_ medicine: Medicine, user: String) {
        updateStock(medicine, by: 1, user: user)
    }
    
    func decreaseStock(_ medicine: Medicine, user: String) {
        updateStock(medicine, by: -1, user: user)
    }
    
    private func updateStock(_ medicine: Medicine, by amount: Int, user: String) {
        guard let id = medicine.id else { return }
        let newStock = medicine.stock + amount
        
        db.collection("medicines").document(id).updateData(["stock": newStock]) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                print("Erreur stock: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    if let index = self.medicines.firstIndex(where: { $0.id == id }) {
                        self.medicines[index].stock = newStock
                    }
                    self.addHistory(
                        action: amount > 0 ? "Augmentation" : "Diminution",
                        user: user,
                        medicineId: id,
                        details: "Stock passé à \(newStock)"
                    )
                }
            }
        }
    }

    func updateMedicine(_ medicine: Medicine, user: String) {
        guard let id = medicine.id else { return }
        do {
            try db.collection("medicines").document(id).setData(from: medicine)
            addHistory(action: "Modification", user: user, medicineId: id, details: "Mise à jour de \(medicine.name)")
        } catch { print("Error update: \(error)") }
    }

    private func addHistory(action: String, user: String, medicineId: String, details: String) {
        let historyEntry = HistoryEntry(medicineId: medicineId, user: user, action: action, details: details)
        try? db.collection("history").document(historyEntry.id ?? UUID().uuidString).setData(from: historyEntry)
    }

    func fetchHistory(for medicine: Medicine) {
        guard let medicineId = medicine.id else { return }
        // Ajout de [weak self] pour l'historique
        db.collection("history").whereField("medicineId", isEqualTo: medicineId).addSnapshotListener { [weak self] (snapshot, _) in
            guard let self = self else { return }
            
            let fetched = snapshot?.documents.compactMap { try? $0.data(as: HistoryEntry.self) } ?? []
            DispatchQueue.main.async { self.history = fetched }
        }
    }
}
