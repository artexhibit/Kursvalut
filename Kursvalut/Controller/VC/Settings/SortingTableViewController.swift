
import UIKit

class SortingTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    private var pickedOrder: String {
        return UserDefaults.standard.string(forKey: "pickedOrder") ?? ""
    }
    private var pickedSectionNumber: Int {
        return UserDefaults.standard.integer(forKey: "pickedSectionNumber")
    }
    private var sections = [
    SortingSection(title: "По имени", subtitle: "Российский рубль", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
    SortingSection(title: "По короткому имени", subtitle: "RUB", options: ["По возрастанию (А→Я)", "По убыванию (Я→А)"]),
    SortingSection(title: "По значению", subtitle: "86,22", options: ["По возрастанию (1→2)", "По убыванию (2→1)"]),
    SortingSection(title: "Своя", subtitle: "в любом порядке", options: ["Включить"])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        currencyManager.configureContentInset(for: tableView, top: 10)
        sections[pickedSectionNumber].isOpened = true
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count * 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let virtualSection: Int = section / 2
        
        if section % 2 == 0 {
            return 1
        } else if sections[virtualSection].isOpened {
            return sections[virtualSection].options.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let virtualSection: Int = indexPath.section / 2
        
        if indexPath.section % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainSortCell", for: indexPath) as! MainSortTableViewCell
            cell.titleLabel.text = sections[virtualSection].title
            cell.subtitleLabel.text = sections[virtualSection].subtitle
            cell.proLabel.isHidden = virtualSection == 3 && !proPurchased ? false : true
            
            if sections[virtualSection].isOpened {
                cell.chevronImage.transform = CGAffineTransform(rotationAngle: .pi / 2)
            } else {
                cell.chevronImage.transform = .identity
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subSortCell", for: indexPath) as! SubSortTableViewCell
            cell.titleLabel.text = sections[virtualSection].options[indexPath.row]
            
            if pickedSectionNumber == virtualSection {
                cell.accessoryType = cell.titleLabel.text == pickedOrder ? .checkmark : .none
            } else {
                cell.accessoryType = .none
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "На экране Валюты" : ""
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let virtualSection: Int = indexPath.section / 2
        
        if indexPath.section % 2 == 0 {
            sections[virtualSection].isOpened.toggle()
            guard let cell = tableView.cellForRow(at: indexPath) as? MainSortTableViewCell else { return }
            
            if virtualSection == 3 && !proPurchased {
                sections[virtualSection].isOpened = false
                tableView.reloadSections([virtualSection], with: .fade)
                PopupView().showPopup(title: "Закрыто", message: "Доступно только в Pro", type: .lock)
            }
            
            UIView.animate(withDuration: 0.3) {
                if self.sections[virtualSection].isOpened {
                    cell.chevronImage.transform = CGAffineTransform(rotationAngle: .pi / 2)
                } else {
                    cell.chevronImage.transform = .identity
                }
            }
            tableView.reloadSections([indexPath.section + 1], with: .fade)
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? SubSortTableViewCell else { return }
            let pickedSection =  sections[virtualSection].title
            let pickedOrder = cell.titleLabel.text ?? ""
            
            if cell.accessoryType != .checkmark {
                for section in 0..<tableView.numberOfSections where section % 2 != 0 {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) else { return }
                        cell.accessoryType = .none
                    }
                }
                cell.accessoryType = .checkmark
            }
            UserDefaults.standard.set(pickedOrder, forKey: "pickedOrder")
            UserDefaults.standard.set(pickedSection, forKey: "pickedSection")
            UserDefaults.standard.set(virtualSection, forKey: "pickedSectionNumber")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
}
