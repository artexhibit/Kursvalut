
import UIKit

class StartViewTableViewController: UITableViewController {
    
    let optionsArray = ["Валюты", "Конвертер"]
    let sectionArray = [(header: "", footer: "Выбранный экран будет открываться сразу после запуска приложения")]
    var pickedStartView: String {
        return UserDefaults.standard.string(forKey: "startView") ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGapBetweenSectionAndNavBar()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
       return sectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionArray[section].footer
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "startViewCell", for: indexPath) as! StartViewTableViewCell
        cell.viewNameLabel.text = optionsArray[indexPath.row]
        cell.accessoryType = cell.viewNameLabel.text == pickedStartView ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? StartViewTableViewCell else { return }
        let pickedSection = indexPath.section
        let pickedOption = cell.viewNameLabel.text
        
        if cell.accessoryType != .checkmark {
            for row in 0..<tableView.numberOfRows(inSection: pickedSection) {
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: pickedSection)) else { return }
                cell.accessoryType = .none
            }
            cell.accessoryType = .checkmark
        }
        UserDefaults.standard.set(pickedOption, forKey: "startView")
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}

//MARK: - StartViewTableViewController Manage Methods

extension StartViewTableViewController {
    func addGapBetweenSectionAndNavBar() {
        tableView.contentInset = UIEdgeInsets(top: 30, left: 0, bottom: 0, right: 0)
    }
}
