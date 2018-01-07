import Foundation

class Project {
    
    var id: String?
    var title: String
    var todos: [Todo]
    var activeTodos: Int
    
    init(title: String) {
        self.title = title
        self.todos = [Todo]()
        self.activeTodos = 0
    }
}
