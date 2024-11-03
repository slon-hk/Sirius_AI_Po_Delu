import SwiftUI
import PDFKit
import EPUBKit

struct BookDetailView: View {
    @ObservedObject var viewModel: BookDetailViewModel
    @State private var fontSize: CGFloat = 18
    @State private var scrollViewOffset: CGFloat = 0

    var body: some View {
        VStack {
            if viewModel.book.fileType == "pdf" {
                PDFViewer(pdfURL: viewModel.getFileURL())
                    .onAppear {
                        viewModel.loadLastReadPosition()
                    }
            } else if viewModel.book.fileType == "txt" || viewModel.book.fileType == "epub" {
                ScrollViewReader { scrollProxy in
                    ScrollView {
                        Text(viewModel.content.isEmpty ? "Загрузка..." : viewModel.content)
                            .font(.system(size: fontSize))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .onAppear {
                                viewModel.loadFileContent()
                                viewModel.scrollToLastReadPosition(using: scrollProxy)
                            }
                    }
                    .onChange(of: viewModel.scrollToPosition) { newValue in
                        if let position = newValue {
                            scrollProxy.scrollTo(position, anchor: .top)
                        }
                    }
                }
            } else {
                Text("Unsupported format")
                    .foregroundColor(.white)
                    .background(Color.black)
            }
            
            HStack {
                Button(action: {
                    if fontSize > 14 {
                        fontSize -= 2
                    }
                }) {
                    Text("A-")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                
                Button(action: {
                    if fontSize < 30 {
                        fontSize += 2
                    }
                }) {
                    Text("A+")
                        .font(.system(size: 20))
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.scrollToLastReadPosition(using: scrollProxy)
                }) {
                    Text("К последней позиции")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
            }
            .padding()
            
            NavigationLink(destination: ChatView()) {
                Text("Чат с AI-ботом")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(5)
            }
            .padding()
            
            ProgressView(value: viewModel.book.progress, total: 100)
                .padding()
        }
        .navigationTitle(viewModel.book.title)
        .onDisappear {
            viewModel.saveLastReadPosition()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

class BookDetailViewModel: ObservableObject {
    @Published var book: Book
    @Published var content: String = ""
    @Published var scrollToPosition: Int?

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

    func scrollToLastReadPosition(using scrollProxy: ScrollViewProxy) {
        if book.lastReadPosition > 0 {
            scrollToPosition = book.lastReadPosition
            if let position = scrollToPosition {
                DispatchQueue.main.async {
                    scrollProxy.scrollTo(position, anchor: .top)
                }
            }
        }
    }
}

struct PDFViewer: UIViewRepresentable {
    let pdfURL: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: pdfURL)
        pdfView.autoScales = true
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {}
}
