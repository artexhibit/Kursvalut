
import UIKit
import StoreKit

class TipJarTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    private var currencyManager = CurrencyManager()
    private var activityIndicator = UIActivityIndicatorView()
    private var tipsArray = [SKProduct]()
    private let tipsID = Set(["ru.igorcodes.kursvalut.smalltip", "ru.igorcodes.kursvalut.mediumtip", "ru.igorcodes.kursvalut.bigtip"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SKPaymentQueue.default().add(self)
        tableViewFooterLabel.text = "Чаевые поддерживают текущую разработку приложения. Спасибо!"
        fetchTips()
    }
    
    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tipsArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tip = tipsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "tipJarCell", for: indexPath) as! TipJarTableViewCell
        cell.tipNameLabel.text = tip.localizedTitle
        cell.tipPriceLabel.text = "\(tip.price) \(tip.priceLocale.currencySymbol ?? "$")"
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tipPayment = SKPayment(product: tipsArray[indexPath.row])
        SKPaymentQueue.default().add(tipPayment)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TipJarTableViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func fetchTips() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: tipsID)
            request.delegate = self
            request.start()
            spinner.startAnimating()
        } else {
            print("You can't make payments")
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.tipsArray = response.products
            self.tipsArray.sort(by: {$0.price.floatValue < $1.price.floatValue})
            self.tableView.reloadData()
            self.spinner.stopAnimating()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                break
            case .purchasing:
                break
            case .deferred:
                break
            @unknown default:
                break
            }
        }
    }
}
