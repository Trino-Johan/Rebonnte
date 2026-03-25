import SwiftUI
import Firebase

@main
struct MediStockApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    // 1. Utilisation de @StateObject pour que la session survive aux cycles de vie de l'app
    @StateObject var sessionStore = SessionStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .onAppear {
                    // 2. lance l'écouteur de session dès l'apparition
                    sessionStore.listen()
                }
                .onDisappear {
                    // 3. GREEN CODE : On coupe l'écouteur quand l'app n'est plus active
                    // pour économiser la batterie et les données.
                    sessionStore.unbind()
                }
        }
    }
}
