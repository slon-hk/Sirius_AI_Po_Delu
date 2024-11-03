import SwiftUI

struct StartPageView: View {
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("По делу")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .padding()
        }
    }
}

struct StartPageView_Previews: PreviewProvider {
    static var previews: some View {
        StartPageView()
    }
}
