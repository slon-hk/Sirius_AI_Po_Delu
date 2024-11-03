import SwiftUI
import Foundation

struct Book: Identifiable, Codable {
    var id = UUID()
    var title: String
    var author: String
    var coverImage: String
    var filePath: String
    var fileType: String
    var lastReadPosition: Int
    var progress: Double
}

class LibraryViewModel: ObservableObject {
    @Published var books: [Book] = []
    
    init() {
        loadBooksFromStorage()
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func saveBooksToStorage(_ books: [Book]) {
        if let encodedBooks = try? JSONEncoder().encode(books) {
            UserDefaults.standard.set(encodedBooks, forKey: "savedBooks")
        }
    }
    
    private func loadBooksFromStorage() {
        if let savedData = UserDefaults.standard.data(forKey: "savedBooks"),
           let decodedBooks = try? JSONDecoder().decode([Book].self, from: savedData) {
            books = decodedBooks
            print("Загружено книг: \(books.count)")
        }
    }
    
    func addBook(from url: URL) {
        do {
            let fileName = url.lastPathComponent
            let targetURL = getDocumentsDirectory().appendingPathComponent(fileName)
            
            let uniqueURL = generateUniqueURL(for: targetURL)
            
            let newBook = Book(title: fileName, author: "Автор", coverImage: "example_cover", filePath: fileName, fileType: url.pathExtension, lastReadPosition: 0, progress: 0.0)

            books.append(newBook)
            saveBooksToStorage(books)
            
            try FileManager.default.copyItem(at: url, to: uniqueURL)
            
        } catch {
            print("Ошибка копирования файла: \(error.localizedDescription)")
        }
    }



    
    private func generateUniqueURL(for url: URL) -> URL {
        var uniqueURL = url
        var counter = 1
        let fileName = url.deletingPathExtension().lastPathComponent
        let fileExtension = url.pathExtension

        while FileManager.default.fileExists(atPath: uniqueURL.path) {
            uniqueURL = getDocumentsDirectory().appendingPathComponent("\(fileName)(\(counter)).\(fileExtension)")
            counter += 1
        }
        
        return uniqueURL
    }
}
