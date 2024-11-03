import SwiftUI

struct ChatView: View {
    @State private var messages: [String] = []
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.self) { message in
                    Text(message)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            HStack {
                TextField("Введите сообщение", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: sendMessage) {
                    Text("Отправить")
                }
                .padding()
            }
        }
        .navigationTitle("Чат с AI")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    private func sendMessage() {
        guard !userInput.isEmpty else { return }
        
        messages.append("Вы: \(userInput)")
        
        // нужен API
        fetchAIResponse(userInput) { response in
            DispatchQueue.main.async {
                messages.append("AI: \(response)")
                userInput = ""
            }
        }
    }
    
    private func fetchAIResponse(_ message: String, completion: @escaping (String) -> Void) {
        let apiKey = "API_KEY"
        let urlString = "https://api.your-ai-service.com/chat"
        
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let parameters: [String: Any] = [
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
        } catch {
            print("Ошибка при сериализации JSON: \(error.localizedDescription)")
            completion("Не удалось получить ответ от AI.")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                completion("Ошибка при обращении к AI.")
                return
            }
            
            guard let data = data else {
                completion("Не получены данные.")
                return
            }
            
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let aiResponse = jsonResponse["response"] as? String {
                    completion(aiResponse)
                } else {
                    completion("Не удалось распознать ответ от AI.")
                }
            } catch {
                print("Ошибка при обработке данных: \(error.localizedDescription)")
                completion("Ошибка при получении ответа от AI.")
            }
        }
        
        task.resume()
    }
}
