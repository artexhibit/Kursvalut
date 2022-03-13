
import UIKit

class TipJarTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    
    private var currencyManager = CurrencyManager()
    private let dataArray = [
        (tipName: "Небольшие чаевые", tipPrice: "149,00 ₽"),
        (tipName: "Средние чаевые", tipPrice: "499,00 ₽"),
        (tipName: "Щедрые чаевые", tipPrice: "999,00 ₽")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 20)
        tableViewFooterLabel.text = "Чаевые поддерживают текущую разработку приложения. Спасибо!"
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipJarCell", for: indexPath) as! TipJarTableViewCell
        cell.tipNameLabel.text = dataArray[indexPath.row].tipName
        cell.tipPriceLabel.text = dataArray[indexPath.row].tipPrice
        return cell
    }
}
