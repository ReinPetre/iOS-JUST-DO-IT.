import UIKit

class AddTodoViewController: UITableViewController {

    @IBOutlet weak var todoDescription: UITextField!
    @IBOutlet weak var todoDueDatePicker: UIDatePicker!
    @IBOutlet weak var todoPriorityPicker: UIPickerView!
    @IBOutlet weak var todoComment: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    
    var todo: Todo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        saveButton.isEnabled = true
        if let todo = todo {
            title = "Edit Todo"
            todoDescription.text = todo.description
            if let dueDate = todo.dueDate {
                dueDateSwitch.setOn(true, animated: false)
                todoDueDatePicker.isEnabled = true
                todoDueDatePicker.isUserInteractionEnabled = true
                todoDueDatePicker.date = dueDate
            }
            let priorityIndex = Todo.Priority.values.index(of: todo.priority)!
            todoPriorityPicker.selectRow(priorityIndex, inComponent: 0, animated: false)
            todoComment.text = todo.comment
        }
        else {
            todoDueDatePicker.isEnabled = false
            todoDueDatePicker.isUserInteractionEnabled = false
        }
        
    }
    
    @IBAction func moveFocus(_ sender: Any) {
        todoDescription.resignFirstResponder()
        todoComment.becomeFirstResponder()
    }
    
    @IBAction func dueDateSwitchToggled(_ sender: UISwitch) {
        if sender.isOn {
            todoDueDatePicker.isEnabled = true
            todoDueDatePicker.isUserInteractionEnabled = true
        }
        else {
            todoDueDatePicker.isEnabled = false
            todoDueDatePicker.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func save(_ sender: Any) {
        if todo != nil {
            performSegue(withIdentifier: "didEditTodo", sender: self)
        } else {
            performSegue(withIdentifier: "didAddTodo", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "didAddTodo" {
            let description =  todoDescription.text!
            if description.isEmpty {
                Alert.showBasic(title: "Incomplete Form", message: "Please fill out the descripttion field", vc: self)
                return
            } else {
                todo!.description = todoDescription.text!
                let priority = Todo.Priority.values[todoPriorityPicker.selectedRow(inComponent: 0)]
                if dueDateSwitch.isOn {
                    todo = Todo(description: description, dueDate: todoDueDatePicker.date, priority: priority)
                }
                else {
                    todo = Todo(description: description, priority: priority)
                }
                if let comment = todoComment.text, !comment.isEmpty {
                    todo!.comment = comment
                }
                print(todo!.description + " " + todo!.priority.rawValue)
            }
        }
        if segue.identifier == "didEditTodo" {
            let description =  todoDescription.text!
            if description.isEmpty {
                Alert.showBasic(title: "Incomplete Form", message: "Please fill out the descripttion field", vc: self)
                return
            } else {
                todo!.description = todoDescription.text!
                if dueDateSwitch.isOn {
                    todo!.dueDate = todoDueDatePicker.date
                } else {
                    todo!.dueDate = nil
                }
                let priority = Todo.Priority.values[todoPriorityPicker.selectedRow(inComponent: 0)]
                todo!.priority = priority
                if let comment = todoComment.text, !comment.isEmpty {
                    todo!.comment = comment
                }
                print(todo!.description + " " + todo!.priority.rawValue)
            }
        }
    }
}

extension AddTodoViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Todo.Priority.values.count
    }
}

extension AddTodoViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Todo.Priority.values[row].rawValue
    }
}

extension AddTodoViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AddTodoViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

