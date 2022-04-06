
import UIKit
import StoreKit

class ProViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var purchaseSpinner: UIActivityIndicatorView!
    @IBOutlet weak var priceSpinner: UIActivityIndicatorView!
    
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    private var proPurchase: SKProduct?
    private let dataArray = [
        (backColor: UIColor(red: 255/255, green: 235/255, blue: 100/255, alpha: 0.3), icon: UIImage(named: "apps.iphone"), iconColor: UIColor.systemYellow, title: "Стартовый экран", description: "Экономьте время - нужный экран будет открываться мгновенно."),
        (backColor: UIColor(red: 0/255, green: 255/255, blue: 90/255, alpha: 0.3), icon: UIImage(named: "arrow.up.arrow.down"), iconColor: UIColor.systemGreen, title: "Сортировка списка валют", description: "Настройте расположение валют в удобном вам порядке."),
        (backColor: UIColor(red: 0/255, green: 100/255, blue: 255/255, alpha: 0.3), icon: UIImage(named: "quote.closing"), iconColor: UIColor.systemBlue, title: "Десятичные знаки", description: "Установите нужное количество знаков после запятой."),
        (backColor: UIColor(red: 255/255, green: 155/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "rublesign.circle"), iconColor: UIColor.systemOrange, title: "Конвертер валют", description: "Добавьте столько валют в конвертер, сколько требуется."),
        (backColor: UIColor(red: 125/255, green: 0/255, blue: 255/255, alpha: 0.3), icon: UIImage(named: "circle.lefthalf.filled"), iconColor: UIColor.systemPurple, title: "Тема", description: "Нравится тёмное оформление? Установите его на постоянной основе."),
        (backColor: UIColor(red: 100/255, green: 70/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "infinity"), iconColor: UIColor.systemBrown, title: "Новые функции", description: "Купите один раз - получите будущие обновления бесплатно!"),
        (backColor: UIColor(red: 255/255, green: 45/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "heart.fill"), iconColor: UIColor.systemRed, title: "Поддержите разработку", description: "Помогите приложению, кототое делает один разработчик.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchForPro()
        purchaseView.layer.cornerRadius = 20
        purchaseButton.layer.cornerRadius = 12
        priceSpinner.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        SKPaymentQueue.default().add(self)
        
        if proPurchased {
            setPurchasedButton()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if proPurchased {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pro"), object: nil)
        }
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func purchaseButtonPressed(_ sender: UIButton) {
        guard let proPurchase = proPurchase else { return }
        
        let proPayment = SKPayment(product: proPurchase)
        SKPaymentQueue.default().add(proPayment)
        purchaseButton.isHidden = true
        purchaseSpinner.startAnimating()
    }
    
}

//MARK: - TableView DataSource Methods

extension ProViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "proCell", for: indexPath) as! ProTableViewCell
        
        cell.circleView.backgroundColor = dataArray[indexPath.row].backColor
        cell.iconView.image = dataArray[indexPath.row].icon
        cell.iconView.tintColor = dataArray[indexPath.row].iconColor
        cell.titleLabel.text = dataArray[indexPath.row].title
        cell.descriptionLabel.text = dataArray[indexPath.row].description
        
        return cell
    }
}

//MARK: - In-App Purchase Methods

extension ProViewController: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    
    func fetchForPro() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: ["ru.igorcodes.kursvalut.pro"])
            request.delegate = self
            request.start()
            priceSpinner.startAnimating()
        } else {
            PopupView().showPopup(title: "Ошибка", message: "Нет разрешения на покупки", type: .failure)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            if let product = response.products.first {
                self.proPurchase = product
                self.priceLabel.text = "всего за \(product.price) \(product.priceLocale.currencySymbol ?? "$")"
                self.priceSpinner.stopAnimating()
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if transaction.transactionState == .purchased {
                DispatchQueue.main.async {
                    self.purchaseButton.isHidden = false
                    self.setPurchasedButton()
                    PopupView().showPopup(title: "Спасибо", message: "Теперь ты в Pro!", type: .purchase)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            } else if transaction.transactionState == .failed {
                guard let error = transaction.error as? NSError else { return }
                
                DispatchQueue.main.async {
                    self.purchaseButton.isHidden = false
                    self.purchaseSpinner.stopAnimating()
                    PopupView().showPopup(title: "Ошибка \(error.code)", message: "Не удалось оплатить", type: .failure)
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        }
    }
    
    //MARK: - User Interface Manage Methods
    
    func setPurchasedButton() {
        UserDefaults.standard.set(true, forKey: "kursvalutPro")
        purchaseButton.backgroundColor = UIColor.systemGreen
        purchaseButton.setTitle("КУПЛЕНО", for: .normal)
        purchaseButton.isUserInteractionEnabled = false
        purchaseSpinner.stopAnimating()
    }
}
