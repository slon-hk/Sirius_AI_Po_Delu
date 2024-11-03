import Foundation

class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published var content: String = ""
    
    init(book: Book) {
        self.book = book
    }
    
    func getFileURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(book.filePath)
    }
    
    func loadFileContent() {
        let fileURL = getFileURL()
        switch book.fileType {
        case "txt":
            loadTXTContent(from: fileURL)
        case "epub":
            loadEPUBContent(from: fileURL)
        case "pdf":
            content = "PDF content will be displayed with a PDFViewer."
        default:
            content = "Unsupported format"
        }
    }
    
    private func loadTXTContent(from url: URL) {
        do {
            content = try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Ошибка загрузки .txt файла: \(error.localizedDescription)")
            content = "Не удалось загрузить текст книги."
        }
    }
    
    private func loadEPUBContent(from url: URL) {
        do {
            let document = try EPUBDocument(url: url)
            content = ""
            for chapter in document.spine.spineReferences {
                if let chapterText = try? chapter.resource?.content {
                    content += chapterText
                }
            }
            if content.isEmpty {
                content = "Не удалось извлечь текст из EPUB."
            }
        } catch {
            print("Ошибка загрузки .epub файла: \(error.localizedDescription)")
            content = "Не удалось загрузить текст книги."
        }
    }
    
    func saveLastReadPosition() {
        UserDefaults.standard.set(book.lastReadPosition, forKey: "lastReadPosition_\(book.id)")
        UserDefaults.standard.set(book.progress, forKey: "progress_\(book.id)")
    }
    
    func loadLastReadPosition() {
        book.lastReadPosition = UserDefaults.standard.integer(forKey: "lastReadPosition_\(book.id)")
        book.progress = UserDefaults.standard.double(forKey: "progress_\(book.id)")
    }
    
    func calculateProgress(scrollOffset: CGFloat, contentHeight: CGFloat) {
        let visiblePercentage = (abs(scrollOffset) / contentHeight) * 100
        book.progress = min(100, max(0, visiblePercentage))
    }
    
    func scrollToLastReadPosition() {
    }
}
