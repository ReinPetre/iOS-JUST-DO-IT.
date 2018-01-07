//
//  TodoDetailsViewController.swift
//  JUST DO IT.
//
//  Created by Rein on 07/01/2018.
//  Copyright © 2018 Rein. All rights reserved.
//

import UIKit

class TodoDetailsViewController: UIViewController {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var daysTillDueDateLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var dueDateTextField: UITextField!
    @IBOutlet weak var daysTillDueDateTextField: UITextField!
    @IBOutlet weak var priorityTextField: UITextField!
    @IBOutlet weak var notesTextView: UITextView!
    
    
    var todo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        descriptionLabel.text = "Description"
        dueDateLabel.text = "Due Date"
        daysTillDueDateLabel.text = "Days Left"
        priorityLabel.text = "Priority"
        notesLabel.text = "Notes"
        
        if let todo = todo {
            descriptionTextField.text = todo.description
            
            if let dueDate = todo.dueDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMMM YYYY"
                dueDateTextField.text = dateFormatter.string(from: dueDate)
                
                let today  = Date()
                let numberOfDaysBetweenDates = daysBetweenDates(startDate: today, endDate: dueDate)
                daysTillDueDateTextField.text = "You have \(numberOfDaysBetweenDates) days left!"
            }
            else {
                dueDateTextField.text = "No due date has been set."
                daysTillDueDateTextField.text = "No due date has been set."
            }
            
            priorityTextField.text = todo.priority.rawValue
            print("This is printed from the TodoDetailsViewController!")
            print(todo.comment)
            print("I just printed the todo comment")
            notesTextView.text = todo.comment
        }
    }
    
    func daysBetweenDates(startDate: Date, endDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([Calendar.Component.day], from: startDate, to: endDate)
        return components.day!
    }
}
