import XCTest
import FirebaseAuth
@testable import MediStock

final class SessionStoreTests: XCTestCase {
    
    var sessionStore: SessionStore!

    override func setUp() {
        super.setUp()
        // initialise un nouveau SessionStore pour chaque test
        sessionStore = SessionStore()
    }

    override func tearDown() {
        sessionStore = nil
        super.tearDown()
    }

    // MARK: - 1. Test de l'état initial
    func testInitialStateIsNil() {
        // Vérifie qu'au lancement, aucune session n'est active par défaut
        XCTAssertNil(sessionStore.session, "La session devrait être nulle à l'initialisation.")
    }

    // MARK: - 2. Test de la logique de déconnexion
    func testSignOutClearsSession() {
        // Given : simule un utilisateur déjà présent dans la session
        let mockUser = User(uid: "abc-123", email: "pharmacien@hopital.fr")
        sessionStore.session = mockUser
        XCTAssertNotNil(sessionStore.session)
        
        // When : appelle la fonction de déconnexion
        // Note: Dans un test unitaire, vérifie ici l'impact sur la variable @Published
        sessionStore.signOut()
        
        // Then : La session doit repasser à nil
        XCTAssertNil(sessionStore.session, "La session devrait être vidée après l'appel de signOut.")
    }

    // MARK: - 3. Test du modèle de données User
    func testUserModelProperties() {
        // Vérifie que la structure User stocke correctement les informations
        let uid = "unique-id"
        let email = "test@medi.com"
        
        let user = User(uid: uid, email: email)
        
        XCTAssertEqual(user.uid, uid)
        XCTAssertEqual(user.email, email)
    }
}
