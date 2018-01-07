import Foundation

class Todo {
    
    enum Priority: String {
        
        case medium = "Medium"
        case high = "High"
        case extremelyHigh = "Extremely High"
        
        static let values: [Priority] = [.medium, .high, .extremelyHigh]
    }
    
    var description: String
    var dueDate: Date?
    var priority: Priority
    var id: String?
    var comment = ""
    
    init(description: String) {
        self.description = description
        self.priority = .medium
    }
    
    convenience init(description: String, priority: Priority) {
        self.init(description: description)
        self.priority = priority
    }
    
    convenience init(description: String, dueDate: Date, priority: Priority) {
        self.init(description: description, priority: priority)
        self.dueDate = dueDate
    }
    
    
    
    
    
    
    
    

    
    
}
