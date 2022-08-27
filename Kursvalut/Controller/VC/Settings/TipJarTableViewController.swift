
import UIKit
import StoreKit

class TipJarTableViewController: UITableViewController {
    
    @IBOutlet weak var tableViewFooterLabel: UILabel!
    @IBOutlet weak var loadCellsSpinner: UIActivityIndicatorView!
    
    private var currencyManager = CurrencyManager()
    private var tipsArray = [SKProduct]()
    private var transactionEnded: Bool = false
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
        
        if transactionEnded {
            cell.tipPriceSpinner.stopAnimating()
            cell.tipPriceLabel.isHidden = false
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        makePurchase(ofTipAt: indexPath)
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
            PopupView().showPopup(title: "Ошибка", message: "У вас нет разрешения на покупки в App Store", type: .failure)
        }
    }
    
    func makePurchase(ofTipAt indexPath: IndexPath) {
        let tipPayment = SKPayment(product: tipsArray[indexPath.row])
        let cell = tableView.cellForRow(at: indexPath) as! TipJarTableViewCell
        
        cell.tipPriceSpinner.startAnimating()
        cell.tipPriceLabel.isHidden = true
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
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    PopupView().showPopup(title: "Успешно", message: "Спасибо! Ты - супер!", type: .purchase)
                }
                transactionEnded = true
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                guard let error = transaction.error else { return }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    PopupView().showPopup(title: "Ошибка", message: "Не удалось оплатить: \(error.localizedDescription)", type: .failure)
                }
                transactionEnded = true
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
}
