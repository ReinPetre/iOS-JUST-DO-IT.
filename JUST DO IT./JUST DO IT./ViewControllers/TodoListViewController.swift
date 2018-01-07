import UIKit
import Firebase

class TodoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodoTextField: UITextField!
    
    var project: Project!
    var todos: [Todo] = []
    private var indexPathSelectedTodo: IndexPath!
    private var dbRef: DatabaseReference!
    private var todosRef: DatabaseReference!
    private var projectDatabaseHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        title = project.title
        
        dbRef = Database.database().reference()
        todosRef = self.dbRef.child("Projects").child(project.id!).child("todos")
        
        getTodos()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        addTodoTextField.returnKeyType = UIReturnKeyType.done
    }
    
    @IBAction func addTodoButtonPressed(_ sender: RoundedButton) {
        insertNewTodo()
    }
    
    @IBAction func doneKeyPressed(_ sender: Any) {
        addTodoTextField.resignFirstResponder()
        insertNewTodo()
    }
    
    
    func insertNewTodo() {
        guard let text = addTodoTextField.text, !text.isEmpty else {
            return
        }
        
        addTodo(Todo(description: addTodoTextField.text!))
        
        addTodoTextField.text = ""
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "addTodo"?:
            break
        case "editTodo"?:
            let destinationVC = segue.destination as! AddTodoViewController
            destinationVC.todo = todos[indexPathSelectedTodo.row]
        case "todoDetails"?:
            let destinationVC = segue.destination as! TodoDetailsViewController
            destinationVC.todo = sender as? Todo
        default:
            fatalError("Unknown segue")
        }
    }
    
    @IBAction func unwindFromTodoDetail(_ segue: UIStoryboardSegue) {
        switch segue.identifier {
        case "didAddTodo"?:
            let destinationVC = segue.source as! AddTodoViewController
            guard let todo = destinationVC.todo, !todo.description.isEmpty else {
                return
            }
            let newTodo = destinationVC.todo
            addTodo(newTodo!)
        case "didEditTodo"?:
            let destinationVC = segue.source as! AddTodoViewController
            guard let todo = destinationVC.todo, !todo.description.isEmpty else {
                return
            }
            let editedTodo = destinationVC.todo
            updateTodo(editedTodo!)
        default:
            fatalError("Unknown segue")
        }
    }
    
    func addTodo(_ todo: Todo) {
        var todoDetails: [String: Any] = [:]
        let key = self.todosRef.childByAutoId().key
        if let dueDate = todo.dueDate {
            todoDetails = ["_id" : key,
                            "description" : todo.description,
                            "dueDate" : dueDate.description,
                            "priority" : todo.priority.rawValue,
                            "comment" : todo.comment]
        } else {
            todoDetails = ["_id" : key,
                           "description" : todo.description,
                           "dueDate" : "",
                           "priority" : todo.priority.rawValue,
                           "comment" : todo.comment]
        }
        
        todosRef.child(key).setValue(todoDetails)
        todos.append(todo)
        tableView.reloadData()
    }
    
    func getTodos() {
        todosRef.observe(.value, with: { (snapshot) in
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                //clearing the list
                self.todos.removeAll()
                //iterating through all the values
                for todos in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let todoObject = todos.value as? [String: AnyObject]
                    let todoDescription  = todoObject?["description"] as? String ?? ""
                    let todoId = todoObject?["_id"] as? String ?? ""
                    let todoDueDate = todoObject?["dueDate"] as? String ?? ""
                    let todoComment = todoObject?["comment"] as? String ?? ""
                    var todoPriority: Todo.Priority
                    switch todoObject?["priority"] as? String ?? "" {
                        case "Medium" : todoPriority = Todo.Priority.medium
                        case "High" : todoPriority = Todo.Priority.high
                        case "Extremely High": todoPriority = Todo.Priority.extremelyHigh
                        default: todoPriority = Todo.Priority.medium
                    }
                    
                    let newTodo: Todo
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                    if todoDueDate == "" {
                        newTodo = Todo(description: todoDescription, priority: todoPriority)
                    } else {
                        newTodo = Todo(description: todoDescription, dueDate: dateFormatter.date(from: todoDueDate)!, priority: todoPriority)
                    }
                    
                    newTodo.id = todoId
                    newTodo.comment = todoComment
                    
                    self.todos.append(newTodo)
                    self.todos.sort(by: { $0.description < $1.description })
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func removeTodo(_ todo: Todo) {
        todosRef.child(todo.id!).setValue(nil)
    }
    
    func updateTodo(_ todo: Todo) {
        var todoDetails: [String: String] = [:]
        if let dueDate = todo.dueDate {
            todoDetails = ["_id" : todo.id!,
                           "description" : todo.description,
                           "dueDate" : dueDate.description,
                           "priority" : todo.priority.rawValue,
                           "comment" : todo.comment]
        } else {
            todoDetails = ["_id" : todo.id!,
                           "description" : todo.description,
                           "dueDate" : "",
                           "priority" : todo.priority.rawValue,
                           "comment" : todo.comment]
        }
        
        todosRef.child(todo.id!).setValue(todoDetails)
        tableView.reloadData()
    }
    
    func detachProjectListener() {
        todosRef.removeObserver(withHandle: projectDatabaseHandle!)
    }
    
    func confirmDeleteTodo(at indexPath: IndexPath) {
        let deleteAlert = UIAlertController(title: "Delete Todo", message: "Are you sure you want to delete this todo?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.removeTodo(self.todos[indexPath.row])
            self.todos.remove(at: indexPath.row)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
//    func createTodoArray() -> [Todo] {
//
//        var tempTodos: [Todo] = []
//        let currentDate = Date()
//
//        let todo1 = Todo(description: "Todo 1", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo2 = Todo(description: "Todo 2", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo3 = Todo(description: "Todo 3", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo4 = Todo(description: "Todo 4", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo5 = Todo(description: "Todo 5", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo6 = Todo(description: "Todo 6", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo7 = Todo(description: "Todo 7", dueDate: currentDate, priority: Todo.Priority.medium)
//
//        tempTodos.append(todo1)
//        tempTodos.append(todo2)
//        tempTodos.append(todo3)
//        tempTodos.append(todo4)
//        tempTodos.append(todo5)
//        tempTodos.append(todo6)
//        tempTodos.append(todo7)
//
//        return tempTodos
//    }
}

extension TodoListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // Determines how many rows the table should show
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // Here you configure every cell
        
        let todo = todos[indexPath.row] // The todo at that row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoCell
        cell.setTodo(todo: todo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let todo = todos[indexPath.row]
        performSegue(withIdentifier: "todoDetails", sender: todo)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let completeAction = UIContextualAction(style: .normal, title: "Done") {
            (action, view, completionHandler) in
            self.removeTodo(self.todos[indexPath.row])
            self.todos.remove(at: indexPath.row)
            completionHandler(true)
        }
        completeAction.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1.0)
        
        return UISwipeActionsConfiguration(actions: [completeAction])
        
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (action, view, completionHandler) in
            self.indexPathSelectedTodo = indexPath
            self.performSegue(withIdentifier: "editTodo", sender: self)
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor.lightGray
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            self.confirmDeleteTodo(at: indexPath)
            tableView.reloadData()
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
    
}

extension TodoListViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TodoListViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

