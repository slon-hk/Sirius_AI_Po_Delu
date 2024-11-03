import Foundation

struct User {
    let id: UUID
    let name: String
    let email: String
    
    init(id: UUID = UUID(), name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
    }
}
