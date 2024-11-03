import Foundation

class FileManagerHelper {
    static let shared = FileManagerHelper()
    
    private init() {}
    
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveBook(_ book: Book, data: Data) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(book.filePath)
        do {
            try data.write(to: fileURL)
            print("Книга сохранена: \(fileURL.path)")
        } catch {
            print("Ошибка при сохранении книги: \(error.localizedDescription)")
        }
    }
    
    func loadBookContent(for book: Book) -> String? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(book.filePath)
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            print("Файл не существует по пути: \(fileURL.path)")
            return nil
        }
        
        do {
            switch book.fileType.lowercased() {
            case "txt":
                return try String(contentsOf: fileURL, encoding: .utf8)
            case "pdf":
                print("PDF файлы не поддерживаются в данный момент.")
                return nil
            case "epub":
                return loadEPUBContent(for: book)
            default:
                print("Неподдерживаемый формат файла.")
                return nil
            }
        } catch {
            print("Ошибка при загрузке текста книги: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func loadEPUBContent(for book: Book) -> String {
        print("Загрузка EPUB файла...")
        return "Содержимое EPUB здесь."
    }
}
