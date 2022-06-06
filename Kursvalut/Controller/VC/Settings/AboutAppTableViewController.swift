
import UIKit
import SafariServices

class AboutAppTableViewController: UITableViewController {
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    private let dataArray = [
        (header: "", data: [(name: "", description: "Привет 👋🏻. Спасибо, что пользуетесь приложением. Если Вам не хватает какой-то функции, то пишите мне на почту. Вы лучшие! 🔝", link: "")]),
        (header: "Источники данных", data: [(name: "cbr-xml-daily.ru", description: "Курсы валют по ЦБ РФ", link: "https://www.cbr-xml-daily.ru"), (name: "exchangerate.host", description: "Forex курс", link: "https://exchangerate.host")]),
        (header: "Иконки", data: [(name: "Flaticon", description: "Флаги стран", link: "https://www.flaticon.com"), (name: "SFSymbols", description: "Системные иконки", link: "https://developer.apple.com/sf-symbols/")])
    ]
    private let sectionNumber = (aboutAppCell: 0, providerNameFirst: 1, providerNameSecond: 2)
    private var appVersion: String {
        guard let dictionary = Bundle.main.infoDictionary else { return "" }
        guard let version = dictionary["CFBundleShortVersionString"] else { return "" }
        return "Версия \(version)"
    }
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appVersionLabel.text = appVersion
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArray[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataArray[section].header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pickedSection = indexPath.section
        
        if pickedSection == sectionNumber.aboutAppCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutAppDeveloperCell", for: indexPath) as! AboutAppDeveloperTableViewCell
            cell.descriptionLabel.text = dataArray[pickedSection].data[indexPath.row].description
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "aboutAppDataProvidersCell", for: indexPath) as! AboutAppDataProvidersTableViewCell
            cell.providerNameLabel.text = dataArray[pickedSection].data[indexPath.row].name
            cell.descriptionLabel.text = dataArray[pickedSection].data[indexPath.row].description
            cell.globeImageView.tintColor = UIColor(named: "\(appColor)")
            return cell
        }
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let pickedSection = indexPath.section
        let pickedCell = indexPath.row
        
        if pickedSection != sectionNumber.aboutAppCell {
            let link = dataArray[pickedSection].data[pickedCell].link
            guard let urlString = URL(string: link) else { return }
            let safariWebView = SFSafariViewController(url: urlString)
            safariWebView.preferredControlTintColor = UIColor(named: "\(appColor)")
            present(safariWebView, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
       return tableView.estimatedSectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
}
