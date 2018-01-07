import UIKit
import Firebase

class ProjectListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addProjectTextField: UITextField!
    
    private var indexPathSelectedRow: IndexPath!
    private var dbRef: DatabaseReference!
    private var projectsRef: DatabaseReference!
    private var projectDatabaseHandle: DatabaseHandle!
    
    var projects = [Project]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        dbRef = Database.database().reference()
        projectsRef = self.dbRef.child("Projects")
        
        getProjects()
        //projects = createTodoArray()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        addProjectTextField.returnKeyType = UIReturnKeyType.done
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //detachProjectListener()
    }

    @IBAction func addButtonPressed(_ sender: RoundedButton) {
        insertNewProject()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        addProjectTextField.resignFirstResponder()
        insertNewProject()
    }
    
    
    func insertNewProject() {
        guard let text = addProjectTextField.text, !text.isEmpty else {
            return
        }
        let newProject = Project(title: addProjectTextField.text!)
        addProject(project: newProject)
        
        let indexPath = IndexPath(row: projects.count - 1, section: 0)
        
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        addProjectTextField.text = ""
        view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProjectToTodos" {
            let destinationVC = segue.destination as! TodoListViewController
            destinationVC.project = sender as? Project
        }
    }
    
    

//    func createTodoArray() -> [Project] {
//
//        var tempProjects: [Project] = []
//
//        let project1 = Project(title: "Project 1")
//        let project2 = Project(title: "Project 2")
//        let project3 = Project(title: "Project 3")
//        let project4 = Project(title: "Project 4")
//        let project5 = Project(title: "Project 5")
//        let project6 = Project(title: "Project 6")
//        let project7 = Project(title: "Project 7")
//
//        var todos: [Todo] = []
//        let currentDate = Date()
//
//        let todo1 = Todo(description: "Todo 1", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo2 = Todo(description: "Todo 2", dueDate: currentDate, priority: Todo.Priority.medium)
//        let todo3 = Todo(description: "Todo 3", dueDate: currentDate, priority: Todo.Priority.high)
//        let todo4 = Todo(description: "Todo 4", dueDate: currentDate, priority: Todo.Priority.high)
//        let todo5 = Todo(description: "Todo 5", dueDate: Date(timeIntervalSinceNow: 1728000.0), priority: Todo.Priority.extremelyHigh)
//
//        todos.append(todo1)
//        todos.append(todo2)
//        todos.append(todo3)
//        todos.append(todo4)
//        todos.append(todo5)
//
//        project1.todos = todos
//        project2.todos = todos
//        project3.todos = todos
//        project4.todos = todos
//        project5.todos = todos
//        project6.todos = todos
//        project7.todos = todos
//
//        tempProjects.append(project1)
//        tempProjects.append(project2)
//        tempProjects.append(project3)
//        tempProjects.append(project4)
//        tempProjects.append(project5)
//        tempProjects.append(project6)
//        tempProjects.append(project7)
//
//
//        return tempProjects
//    }
    
    func confirmDeleteProject(at indexPath: IndexPath) {
        let deleteAlert = UIAlertController(title: "Delete Project", message: "Are you sure you want to delete this project?", preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action: UIAlertAction!) in
            self.removeProject(project: self.projects[indexPath.row])
            //self.projects.remove(at: indexPath.row)
            
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        deleteAlert.addAction(deleteAction)
        deleteAlert.addAction(cancelAction)
        
        self.present(deleteAlert, animated: true, completion: nil)
    }
    
    func showEditPopUp(for project: Project) {
        
        let alertController = UIAlertController(title: project.title, message: "Give new project title ", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Enter", style: .default) { (_) in
            
            let id = project.id
            
            guard let text = alertController.textFields?[0].text, !text.isEmpty else {
                return
            }
            
            let title = alertController.textFields?[0].text
            
            self.updateProject(id: id!, title: title!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.text = project.title
        }
    
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func addProject(project: Project) {
        let key = self.projectsRef.childByAutoId().key
        let projectDetails: [String : Any] = ["_id" : key,
                              "title" : project.title]
        projectsRef.child(key).setValue(projectDetails)
        project.id = key
        self.projects.append(project)
    }
    
    func getProjects() {
        projectsRef.observe(.value, with: { (snapshot) in
            //if the reference have some values
            if snapshot.childrenCount > 0 {
                //clearing the list
                self.projects.removeAll()
                //iterating through all the values
                for projects in snapshot.children.allObjects as! [DataSnapshot] {
                    //getting values
                    let projectObject = projects.value as? [String: AnyObject]
                    let projectTitle  = projectObject?["title"] as? String ?? ""
                    let projectId  = projectObject?["_id"] as? String ?? ""
                    let projectTodos = projectObject?["todos"] as? [String : Any] ?? [:]
                    
                    let newProject = Project(title: projectTitle)
                    newProject.id = projectId
                    newProject.activeTodos = projectTodos.count
                    
                    //appending it to list
                    self.projects.append(newProject)
                    self.projects.sort(by: { $0.title < $1.title })
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func removeProject(project: Project) {
        projectsRef.child(project.id!).setValue(nil)
    }
    
    func detachProjectListener() {
        projectsRef.removeObserver(withHandle: projectDatabaseHandle!)
    }
    
    func updateProject(id: String, title: String) {
        let projectDetails = ["_id" : id,
                      "title" : title ]
        
        projectsRef.child(id).setValue(projectDetails)
    }
}


extension ProjectListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // Determines how many rows the table should show
        return projects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // Here you configure every cell
        
        let project = projects[indexPath.row] // The todo at that row
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell", for: indexPath) as! ProjectCell
        cell.setProject(project: project)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let project = projects[indexPath.row]
        performSegue(withIdentifier: "ProjectToTodos", sender: project)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {
            (action, view, completionHandler) in
            self.showEditPopUp(for: self.projects[indexPath.row])
            completionHandler(true)
        }
        editAction.backgroundColor = UIColor.lightGray
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {
            (action, view, completionHandler) in
            self.indexPathSelectedRow = indexPath
            self.confirmDeleteProject(at: indexPath)
            tableView.reloadData()
            completionHandler(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }
}

extension ProjectListViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ProjectListViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
