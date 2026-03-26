import Foundation
import Firebase

class SessionStore: ObservableObject {
    @Published var session: User?
    var handle: AuthStateDidChangeListenerHandle?

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let user = user {
                    self.session = User(uid: user.uid, email: user.email)
                } else {
                    self.session = nil
                }
            }
        }
    }

    func signUp(email: String, password: String) {
        // Ajout de [weak self] pour éviter de retenir le Store en mémoire inutilement
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.session = User(uid: result?.user.uid ?? "", email: result?.user.email ?? "")
                }
            }
        }
    }

    func signIn(email: String, password: String) {
        // Ajout de [weak self] ici également
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error signing in: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    self.session = User(uid: result?.user.uid ?? "", email: result?.user.email ?? "")
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.session = nil
        } catch let error {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    func unbind() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

struct User {
    var uid: String
    var email: String?
}
