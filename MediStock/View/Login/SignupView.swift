import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @EnvironmentObject var session: SessionStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Créer un compte")
                        .font(.largeTitle).bold()
                    Text("Rejoignez la gestion MediStock.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .accessibilityLabel("Entrez votre adresse email")

                    SecureField("Mot de passe", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Créez un mot de passe")

                    SecureField("Confirmer le mot de passe", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .accessibilityLabel("Confirmez votre mot de passe")
                }
                .padding(.horizontal)

                Button(action: {
                    if password == confirmPassword {
                        session.signUp(email: email, password: password)
                    }
                }) {
                    Text("S'inscrire")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(password == confirmPassword && !email.isEmpty ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(password != confirmPassword || email.isEmpty)
                .padding(.horizontal)
                .accessibilityHint("Crée votre compte et vous connecte automatiquement")

                Spacer()
            }
            .padding(.top, 50)
        }
    }
}
