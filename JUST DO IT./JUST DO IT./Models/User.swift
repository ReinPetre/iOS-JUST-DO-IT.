import Foundation

class User {
    
    var firstName: String
    var lastName: String
    var email: String
    var username: String
    var password: String
    var projects: [Project]
    
    init(firstName: String, lastName: String, email: String, username: String, password: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.password = password
        self.projects = [Project]()
    }
}
