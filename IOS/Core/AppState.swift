import SwiftUI

class AppState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var isLoading = true
    
    init() {
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading = false
            self.isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
            print("Check login status: isLoggedIn = \(self.isLoggedIn)")
        }
    }
    
    func login(email: String, password: String) {
        if !email.isEmpty && !password.isEmpty {
            isLoggedIn = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }
    }
    
    func signUp(email: String, password: String, confirmPassword: String) {
        if password == confirmPassword && !email.isEmpty && !password.isEmpty {
            isLoggedIn = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
        }
    }
}
