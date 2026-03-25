import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var session: SessionStore

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 30) {
                    Image(systemName: "pills.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .accessibilityHidden(true)

                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.none)
                            .accessibilityLabel("Email de connexion")
                        
                        SecureField("Mot de passe", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .accessibilityLabel("Mot de passe de connexion")
                    }
                    .padding(.horizontal)

                    VStack(spacing: 20) {
                        Button(action: {
                            session.signIn(email: email, password: password)
                        }) {
                            Text("Se connecter")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        // Navigation vers la création de compte
                        NavigationLink(destination: SignUpView()) {
                            Text("Pas encore de compte ? **S'inscrire**")
                                .foregroundColor(.blue)
                        }
                        .accessibilityLabel("Aller à l'écran de création de compte")
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationBarHidden(true)
        }
    }
}
