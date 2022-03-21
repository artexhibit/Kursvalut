
import UIKit

class ProViewController: UIViewController {
    
    @IBOutlet weak var purchaseButton: UIButton!
    @IBOutlet weak var purchaseView: UIView!
    @IBOutlet weak var purchaseLabel: UILabel!
    
    private let dataArray = [
        (backColor: UIColor(red: 255/255, green: 235/255, blue: 100/255, alpha: 0.3), icon: UIImage(named: "apps.iphone"), iconColor: UIColor.systemYellow, title: "Стартовый экран", description: "Экономьте время - нужный экран будет открываться мгновенно."),
        (backColor: UIColor(red: 0/255, green: 255/255, blue: 90/255, alpha: 0.3), icon: UIImage(named: "arrow.up.arrow.down"), iconColor: UIColor.systemGreen, title: "Сортировка списка валют", description: "Настройте расположение валют в удобном вам порядке."),
        (backColor: UIColor(red: 0/255, green: 100/255, blue: 255/255, alpha: 0.3), icon: UIImage(named: "textformat.123"), iconColor: UIColor.systemBlue, title: "Десятичные знаки", description: "Установите нужное количество знаков после запятой."),
        (backColor: UIColor(red: 255/255, green: 155/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "list.star"), iconColor: UIColor.systemOrange, title: "Конвертер валют", description: "Добавьте столько валют в конвертер, сколько нужно вам."),
        (backColor: UIColor(red: 125/255, green: 0/255, blue: 255/255, alpha: 0.3), icon: UIImage(named: "circle.lefthalf.filled"), iconColor: UIColor.systemPurple, title: "Тема", description: "Нравится тёмное оформление? Установите его на постоянной основе."),
        (backColor: UIColor(red: 100/255, green: 70/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "infinity"), iconColor: UIColor.systemBrown, title: "Новые функции", description: "Купите один раз - получите будущие обновления бесплатно!"),
        (backColor: UIColor(red: 255/255, green: 45/255, blue: 0/255, alpha: 0.3), icon: UIImage(named: "heart.fill"), iconColor: UIColor.systemRed, title: "Поддержите разработку", description: "Помогите приложению, кототое делает один разработчик.")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        purchaseView.layer.cornerRadius = 20
        purchaseButton.layer.cornerRadius = 12
        purchaseLabel.text = "Всего за 99 ₽"
    }
    
    @IBAction func dismissButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
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
