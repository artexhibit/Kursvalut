
import UIKit
import StoreKit

class TipJarTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    @IBOutlet weak var loadCellsSpinner: UIActivityIndicatorView!
    
    private var currencyManager = CurrencyManager()
    private var activityIndicator = UIActivityIndicatorView()
    private var tipsArray = [SKProduct]()
    private var transactionEnded: Bool = false
    private let tipsID = Set(["ru.igorcodes.kursvalut.smalltip", "ru.igorcodes.kursvalut.mediumtip", "ru.igorcodes.kursvalut.bigtip"])
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        if transactionEnded {
            cell.tipPriceSpinner.stopAnimating()
            cell.tipPriceLabel.isHidden = false
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        makePurchase(ofTipAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - In-App Purchase Methods

extension TipJarTableViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func fetchTips() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: tipsID)
            request.delegate = self
            request.start()
            loadCellsSpinner.startAnimating()
        } else {
            print("You can't make payments")
        }
    }
    
    func makePurchase(ofTipAt indexPath: IndexPath) {
        let tipPayment = SKPayment(product: tipsArray[indexPath.row])
        let cell = tableView.cellForRow(at: indexPath) as! TipJarTableViewCell
        
        cell.tipPriceSpinner.startAnimating()
        cell.tipPriceLabel.isHidden = true
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(tipPayment)
    }

    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.tipsArray = response.products
            self.tipsArray.sort(by: {$0.price.floatValue < $1.price.floatValue})
            self.tableView.reloadData()
            self.loadCellsSpinner.stopAnimating()
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                transactionEnded = true
                tableView.reloadData()
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                if let error = transaction.error {
                    let errorDescription = error.localizedDescription
                    print(errorDescription)
                }
                transactionEnded = true
                tableView.reloadData()
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
