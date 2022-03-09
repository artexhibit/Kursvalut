
import UIKit

class AboutAppTableViewController: UITableViewController {
    
    let dataArray = [
        (header: "", footer: "", data: ["Привет. Меня зовут Игорь, и я единственный разработчик Kursvalut. Спасибо, что пользуетесь приложением. Если Вам не хватает какой-то функции, то смело пишите мне на почту. Вы лучшие! ❤️"])
    ]
    var appVersion: String {
        guard let dictionary = Bundle.main.infoDictionary else { return "" }
        guard let version = dictionary["CFBundleShortVersionString"] else { return "" }
        return "Версия \(version)"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "aboutAppDeveloperCell", for: indexPath) as! AboutAppDeveloperTableViewCell
        cell.descriptionLabel.text = dataArray[0].data[0]
        cell.appVersionLabel.text = appVersion
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return tableView.estimatedSectionFooterHeight
    }
}
