import SwiftUI
import UIKit

struct BookView: View {
    @State private var bookContent: String = ""
    @State private var documentPickerPresented = false

    var body: some View {
        VStack {
            Text(bookContent)
                .padding()
            Button("Открыть книгу") {
                documentPickerPresented.toggle()
            }
            .sheet(isPresented: $documentPickerPresented) {
                DocumentPicker(bookContent: $bookContent)
            }
        }
        .navigationTitle("Читалка")
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var bookContent: String

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.text, .pdf])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                do {
                    parent.bookContent = try String(contentsOf: url)
                } catch {
                    print("Ошибка чтения файла: \(error)")
                }
            }
        }
    }
}
