import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var todoDescription: UILabel!
    @IBOutlet weak var todoDueDate: UILabel!
    
    func setTodo(todo: Todo) {
        
        let dayMonthFormatter = DateFormatter()
        dayMonthFormatter.dateFormat = "d MMM"
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.dateFormat = "EEEE"
        
        setPriorityColoredUnderline(for: todo, description: todo.description)
        
        if let dueDate = todo.dueDate {
            
            let today  = Date()
            let numberOfDaysBetweenDates = daysBetweenDates(startDate: today, endDate: dueDate)
            
            if numberOfDaysBetweenDates <= 7 {
                todoDueDate.text = weekdayFormatter.string(from: dueDate)
            }
            else {
                todoDueDate.text = dayMonthFormatter.string(from: dueDate)
            }
        }
        else {
            todoDueDate.text = ""
        }
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }
    
    func setPriorityColoredUnderline(for todo: Todo, description: String) {

        let labelString = description
        
        let underLineColor: UIColor
        switch todo.priority {
            case .medium: underLineColor = .blue
            case .high: underLineColor = .orange
            case.extremelyHigh: underLineColor = .red
        }
        
        let underLineStyle = NSUnderlineStyle.styleSingle.rawValue
        
        let labelAtributes:[NSAttributedStringKey : Any]  = [
            NSAttributedStringKey.underlineStyle: underLineStyle,
            NSAttributedStringKey.underlineColor: underLineColor
        ]
        
        let underlineAttributedString = NSAttributedString(string: labelString,
                                                           attributes: labelAtributes)
        
        todoDescription.attributedText = underlineAttributedString
    }
}
