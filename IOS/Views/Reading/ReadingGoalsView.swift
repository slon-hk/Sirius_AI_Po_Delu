import SwiftUI

struct ReadingGoalsView: View {
    @State private var daysToRead = 1
    @State private var shouldCheckKnowledge = false
    @State private var selectedDate = Date()
    
    // Замыкание для передачи данных
    var onSave: (Int, Bool, Date) -> Void

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("За сколько дней хотите прочитать книгу?")
                .font(.headline)
                .foregroundColor(.white)
                .padding()

            Picker("Дней", selection: $daysToRead) {
                ForEach(1...30, id: \.self) { day in
                    Text("\(day) \(getDayString(day: day))").tag(day)
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .padding()

            Toggle(isOn: $shouldCheckKnowledge) {
                Text("Хотите проверять свои знания во время чтения?")
                    .foregroundColor(.white)
            }
            .padding()

            DatePicker("Выберите дату проверки:", selection: $selectedDate, displayedComponents: .date)
                .padding()
                .foregroundColor(.white)

            Button(action: {
                // Вызов замыкания для передачи данных обратно
                onSave(daysToRead, shouldCheckKnowledge, selectedDate)
                presentationMode.wrappedValue.dismiss() // Закрыть вкладку
            }) {
                Text("Сохранить цели чтения")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Spacer()
        }
        .background(Color.black.ignoresSafeArea())
    }

    // Функция для получения правильного окончания слова "день"
    private func getDayString(day: Int) -> String {
        switch day {
        case 1, 21:
            return "день"
        case 2, 3, 4, 22, 23, 24:
            return "дня"
        default:
            return "дней"
        }
    }
}
