import Foundation
import Firebase

class DB {
    // reference to Firebase
    private var dbRef: DatabaseReference!
    private var projectsRef: DatabaseReference
    private var projectDatabaseHandle: DatabaseHandle?
    
    init() {
        self.dbRef = Database.database().reference()
        self.projectsRef = self.dbRef.child("Projects")
    }
    
    func insertProject(project: Project) {
        let key = self.projectsRef.childByAutoId().key
        let projectDetails = ["id" : key,
            "title" : project.title]
        self.projectsRef.child(key).setValue(projectDetails)
    }
    
    func getProjects() -> [Project] {
        var projects = [Project]()
        projectDatabaseHandle = self.projectsRef.observe(.childAdded) { (snapshot) in
            // id
            let projectId = snapshot.key
            // Other values as dictionary
            let value = snapshot.value as? NSDictionary
            // Get necessary values
            let projectTitle = value?["title"] as? String ?? ""
            // Create new project
            let newProject = Project(title: projectTitle)
            newProject.id = projectId
            // Add project to array
            print(newProject)
            projects.append(newProject)
            // Return the project array
        }
        print(projects)
        return projects
    }
    
    func removeProject(project: Project) {
        projectsRef.child(project.id!).setValue(nil)
    }
    
    func detachProjectListener() {
        projectsRef.removeObserver(withHandle: projectDatabaseHandle!)
    }
}
