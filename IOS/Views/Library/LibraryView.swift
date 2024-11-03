import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @ObservedObject var viewModel = LibraryViewModel()
    @State private var isFilePickerPresented = false

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(viewModel.books) { book in
                            VStack {
                                NavigationLink(destination: BookDetailView(viewModel: BookDetailViewModel(book: book))) {
                                    VStack {
                                        Image(book.coverImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 150)
                                            .background(Color.gray)
                                            .cornerRadius(8)
                                        Text(book.title)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text("\(Int(book.progress * 100))% прочитано")
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    isFilePickerPresented = true
                }) {
                    Text("Загрузить книги")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .bottom])
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $isFilePickerPresented) {
                FilePicker { url in
                    if let url = url {
                        viewModel.addBook(from: url)
                    }
                }
            }
        }
    }
}
