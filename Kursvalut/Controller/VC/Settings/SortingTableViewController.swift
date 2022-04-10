
import UIKit

class SortingTableViewController: UITableViewController {
    
    private var currencyManager = CurrencyManager()
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
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
    }
    
    //MARK: - TableView DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = sections[section]
        if section.isOpened {
            return section.options.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "mainSortCell", for: indexPath) as! MainSortTableViewCell
            cell.titleLabel.text = sections[indexPath.section].title
            cell.subtitleLabel.text = sections[indexPath.section].subtitle
            cell.proLabel.isHidden = indexPath.section == 3 && !proPurchased ? false : true
            
            if sections[indexPath.section].isOpened {
                cell.chevronImage.transform = CGAffineTransform(rotationAngle: .pi/2)
            } else {
                cell.chevronImage.transform = .identity
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "subSortCell", for: indexPath) as! SubSortTableViewCell
            cell.titleLabel.text = sections[indexPath.section].options[indexPath.row - 1]
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = section == 0 ? "На экране Валюты" : ""
        return title
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            sections[indexPath.section].isOpened = !sections[indexPath.section].isOpened
            
            guard let cell = tableView.cellForRow(at: indexPath) as? MainSortTableViewCell else { return }
            
            UIView.animate(withDuration: 0.3) {
                if self.sections[indexPath.section].isOpened {
                    cell.chevronImage.transform = CGAffineTransform(rotationAngle: .pi/2)
                } else {
                    cell.chevronImage.transform = .identity
                }
            } completion: { _ in
                tableView.reloadSections([indexPath.section], with: .none)
            }
        } else {
            guard let cell = tableView.cellForRow(at: indexPath) as? SubSortTableViewCell else { return }
            let pickedSection =  sections[indexPath.section].title
            let pickedOption = cell.titleLabel.text ?? ""
            
            if cell.accessoryType != .checkmark {
                for section in 0..<tableView.numberOfSections {
                    for row in 0..<tableView.numberOfRows(inSection: section) {
                        guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: section)) else { return }
                        cell.accessoryType = .none
                    }
                }
                cell.accessoryType = .checkmark
            }
            print("tapped cell at row \(indexPath.row) called \(pickedOption) in section \(indexPath.section) called \(pickedSection)")
        }
        
        if indexPath.section == 3 && !proPurchased {
            sections[3].isOpened = false
            tableView.reloadSections([3], with: .none)
            PopupView().showPopup(title: "Закрыто", message: "Доступно только в Pro", type: .lock)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        tableView.estimatedSectionHeaderHeight
    }
}
