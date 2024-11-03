import SwiftUI

struct LoginOrSignUpView: View {
    @EnvironmentObject var appState: AppState
    @State private var isLogin = true
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                Text(isLogin ? "Вход" : "Регистрация")
                    .font(.title)
                    .foregroundColor(.white)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                SecureField("Пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)

                if !isLogin {
                    SecureField("Подтверждение пароля", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                }

                Button(action: {
                    if isLogin {
                        appState.login(email: email, password: password)
                    } else {
                        appState.signUp(email: email, password: password, confirmPassword: confirmPassword)
                    }
                }) {
                    Text(isLogin ? "Войти" : "Зарегистрироваться")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                Button(action: {
                    isLogin.toggle()
                }) {
                    Text(isLogin ? "Нет аккаунта? Зарегистрируйтесь" : "Уже есть аккаунт? Войдите")
                        .foregroundColor(.blue)
                }
                .padding()
            }
            .padding(.horizontal)
        }
    }
}
