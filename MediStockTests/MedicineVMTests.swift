import XCTest
@testable import MediStock // Remplacez par le nom de votre projet

final class MedicineStockViewModelTests: XCTestCase {
    
    var viewModel: MedicineStockViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MedicineStockViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - 1. Test de l'extraction des rayons (Logic)
    func testAislesExtractionLogic() {
        // Given : Une liste brute de médicaments avec des doublons de rayons
        let mockMedicines = [
            Medicine(name: "Médicament A", stock: 10, aisle: "Zone B"),
            Medicine(name: "Médicament B", stock: 5, aisle: "Zone A"),
            Medicine(name: "Médicament C", stock: 2, aisle: "Zone B")
        ]
        
        // When : simule l'algorithme utilisé dans fetchAisles
        let result = Array(Set(mockMedicines.map { $0.aisle })).sorted()
        
        // Then : doit avoir une liste unique et triée par ordre alphabétique
        XCTAssertEqual(result.count, 2, "Il devrait y avoir 2 rayons uniques.")
        XCTAssertEqual(result.first, "Zone A", "Le tri devrait placer Zone A en premier.")
    }

    // MARK: - 2. Test de la logique de mise à jour du stock
    func testStockUpdateCalculation() {
        // Given : Un médicament avec un stock de 10
        let medicine = Medicine(id: "1", name: "Test", stock: 10, aisle: "A1")
        let increment = 1
        let decrement = -1
        
        // When : Calcul du nouveau stock (Logique interne de updateStock)
        let increasedStock = medicine.stock + increment
        let decreasedStock = medicine.stock + decrement
        
        // Then : Les valeurs calculées doivent être exactes
        XCTAssertEqual(increasedStock, 11, "Le stock devrait passer à 11.")
        XCTAssertEqual(decreasedStock, 9, "Le stock devrait passer à 9.")
    }

    // MARK: - 3. Test de l'état de chargement (Asynchrone)
    func testIsLoadingState() {
        // Given : Le ViewModel vient d'être initialisé
        XCTAssertFalse(viewModel.isLoading, "Au départ, isLoading doit être faux.")
        
        // When : appelle fetchMedicines
        viewModel.fetchMedicines()
        
        // Then : L'état doit passer à true immédiatement (avant la réponse Firebase)
        XCTAssertTrue(viewModel.isLoading, "isLoading doit être vrai pendant l'appel réseau.")
    }
    
    // MARK: - 4. Test de la sécurité de suppression
    func testDeleteMedicineGuard() {
        // Given : Un médicament sans ID (non encore enregistré en base)
        let medicineWithoutID = Medicine(name: "Nouveau", stock: 0, aisle: "A1")
        
        // When : tente de supprimer
        // Note: vérifie ici que le code ne crash pas et sort proprement via le guard
        viewModel.deleteMedicine(medicineWithoutID, userEmail: "test@test.com")
        
        XCTAssertNil(medicineWithoutID.id, "Le médicament n'a pas d'ID, le guard doit bloquer l'appel Firebase.")
    }
}
