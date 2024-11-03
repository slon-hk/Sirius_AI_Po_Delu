import SwiftUI

@main
struct po_deluApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if appState.isLoading {
                    StartPageView()
                        .background(Color.black.ignoresSafeArea())
                } else if appState.isLoggedIn {
                    ContentView()
                        .environmentObject(appState)
                } else {
                    LoginOrSignUpView()
                        .environmentObject(appState)
                        .ignoresSafeArea()
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
    
