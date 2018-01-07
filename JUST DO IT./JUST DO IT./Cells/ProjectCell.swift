import UIKit

class ProjectCell: UITableViewCell {

    @IBOutlet weak var projectTitle: UILabel!
    @IBOutlet weak var activeTodosCount: UILabel!
    
    
    func setProject(project: Project) {
        projectTitle.text = project.title
        activeTodosCount.text = String(project.activeTodos)
    }
}

