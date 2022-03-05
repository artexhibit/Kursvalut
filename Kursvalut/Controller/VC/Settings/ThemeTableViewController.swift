
import UIKit

class ThemeTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private let optionsArray = ["Светлая", "Тёмная", "Как в системе"]
    private let sectionArray = [(header: "", footer: "Принудительно установить один из вариантов оформления или переключать его согласно системным настройкам устройства")]
    private var pickedTheme: String {
        return UserDefaults.standard.string(forKey: "pickedTheme") ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 30)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath) as! ThemeTableViewCell
        cell.themeNameLabel.text = optionsArray[indexPath.row]
        cell.accessoryType = cell.themeNameLabel.text == pickedTheme ? .checkmark : .none
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) as? ThemeTableViewCell else { return }
        let pickedSection = indexPath.section
        let pickedOption = cell.themeNameLabel.text
        
        var themeStyle: UIUserInterfaceStyle {
            if pickedOption == "Светлая" {
                return .light
            } else if pickedOption == "Тёмная" {
                return .dark
            } else {
                return .unspecified
            }
        }
        
        if cell.accessoryType != .checkmark {
            for row in 0..<tableView.numberOfRows(inSection: pickedSection) {
                guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: pickedSection)) else { return }
                cell.accessoryType = .none
            }
            cell.accessoryType = .checkmark
        }
        UserDefaults.standard.set(pickedOption, forKey: "pickedTheme")
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = windowScene.windows.first else { return }
        UIView.transition(with: firstWindow, duration: 0.3, options: .transitionCrossDissolve, animations: { firstWindow.overrideUserInterfaceStyle = themeStyle }, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
    
}
