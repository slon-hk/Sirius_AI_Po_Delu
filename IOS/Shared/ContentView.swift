import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        LibraryView()
            .background(Color.black.ignoresSafeArea())
    }
}
