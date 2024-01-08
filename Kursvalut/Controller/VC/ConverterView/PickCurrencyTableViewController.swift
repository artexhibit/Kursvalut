
import UIKit
import CoreData

class PickCurrencyTableViewController: UITableViewController {
    
    private var bankOfRussiaFRC: NSFetchedResultsController<Currency>!
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var currencyManager = CurrencyManager()
    private let coreDataManager = CurrencyCoreDataManager()
    private let converterManager = ConverterManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupSearchController()
        tableView.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - TableView Delegate & DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections!.count : forexFRC.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].name : forexFRC.sections![section].name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sectionTitles = [String]()
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            guard let sections = bankOfRussiaFRC?.sections else { return nil }
            
            for section in sections {
                guard let firstCharacter = section.name.first else { return nil }
                sectionTitles.append(String(firstCharacter))
            }
        } else {
            guard let sections = forexFRC?.sections else { return nil }
            
            for section in sections {
                guard let firstCharacter = section.name.first else { return nil }
                sectionTitles.append(String(firstCharacter))
            }
        }
        return sectionTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.section(forSectionIndexTitle: title, at: index) : forexFRC.section(forSectionIndexTitle: title, at: index)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserDefaultsManager.pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickCurrencyCell", for: indexPath) as! PickCurrencyTableViewCell
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.picker.image = currency.isForConverter ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        } else {
            let currency = forexFRC.object(at: indexPath)
            
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.picker.image = currency.isForConverter ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            var currentAmount = UserDefaultsManager.ConverterVC.amountOfPickedBankOfRussiaCurrencies
            let bankOfRussiaCurrencies = coreDataManager.fetchCurrencies(entityName: Currency.self)
            let bankOfRussiaCurrency = bankOfRussiaFRC.object(at: indexPath)
            
            bankOfRussiaCurrency.isForConverter = !bankOfRussiaCurrency.isForConverter
            bankOfRussiaCurrency.isForConverter ? (currentAmount += 1) : (currentAmount -= 1)
            
            if bankOfRussiaCurrency.isForConverter {
                if UserDefaultsManager.proPurchased {
                    converterManager.setRow(for: bankOfRussiaCurrency, in: bankOfRussiaCurrencies)
                } else if !UserDefaultsManager.proPurchased && currentAmount <= 3 {
                    converterManager.setRow(for: bankOfRussiaCurrency, in: bankOfRussiaCurrencies)
                } else {
                    bankOfRussiaCurrency.isForConverter = false
                    currentAmount = 3
                    PopupQueueManager.shared.addPopupToQueue(title: "Максимум 3 валюты", message: "Безлимит доступен в Pro", style: .lock)
                }
            } else {
                bankOfRussiaCurrency.isForConverter = false
                bankOfRussiaCurrency.rowForConverter = 0
            }
            UserDefaultsManager.ConverterVC.amountOfPickedBankOfRussiaCurrencies = currentAmount
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCells"), object: nil, userInfo: ["currencyWasAdded": bankOfRussiaCurrency.isForConverter])
        } else if UserDefaultsManager.pickedDataSource == "Forex" {
            var currentAmount = UserDefaultsManager.ConverterVC.amountOfPickedForexCurrencies
            let forexCurrencies = coreDataManager.fetchCurrencies(entityName: ForexCurrency.self)
            let forexCurrency = forexFRC.object(at: indexPath)
            
            forexCurrency.isForConverter = !forexCurrency.isForConverter
            forexCurrency.isForConverter ? (currentAmount += 1) : (currentAmount -= 1)
            
            if forexCurrency.isForConverter {
                if UserDefaultsManager.proPurchased {
                    converterManager.setRow(for: forexCurrency, in: forexCurrencies)
                } else if !UserDefaultsManager.proPurchased && currentAmount <= 3 {
                    converterManager.setRow(for: forexCurrency, in: forexCurrencies)
                } else {
                    forexCurrency.isForConverter = false
                    currentAmount = 3
                    PopupQueueManager.shared.addPopupToQueue(title: "Максимум 3 валюты", message: "Безлимит доступен в Pro", style: .lock)
                }
            } else {
                forexCurrency.isForConverter = false
                forexCurrency.rowForConverter = 0
            }
            UserDefaultsManager.ConverterVC.amountOfPickedForexCurrencies = currentAmount
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateCells"), object: nil, userInfo: ["currencyWasAdded": forexCurrency.isForConverter])
        }
        PersistenceController.shared.saveContext()
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension PickCurrencyTableViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController(with searchPredicate: NSPredicate? = nil) {
        UserDefaults.sharedContainer.set(true, forKey: "pickCurrencyRequest")
        let sortDescriptor = NSSortDescriptor(key: "fullName", ascending: true)
        var searchCompoundPredicate: NSCompoundPredicate {
            let additionalPredicate = NSPredicate(format: "isForCurrencyScreen == YES")
            
            if let searchPredicate = searchPredicate {
                return NSCompoundPredicate(type: .and, subpredicates: [searchPredicate, additionalPredicate])
            } else {
                return NSCompoundPredicate(type: .and, subpredicates: [additionalPredicate])
            }
        }
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: searchCompoundPredicate, and: sortDescriptor)
            bankOfRussiaFRC.delegate = self
            try? bankOfRussiaFRC.performFetch()
        } else {
            forexFRC = coreDataManager.createForexCurrencyFRC(with: searchCompoundPredicate, and: sortDescriptor)
            forexFRC.delegate = self
            try? forexFRC.performFetch()
        }
        tableView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: indexPath, to: newIndexPath)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .none)
            }
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .none)
            }
        default:
            tableView.reloadData()
        }
    }
}

//MARK: - UISearchController Setup & Delegate Methods

extension PickCurrencyTableViewController: UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по коду и имени валюты"
        searchController.searchBar.setValue("Готово", forKey: "cancelButtonText")
        definesPresentationContext = true
        navigationItem.searchController = searchController
        navigationController?.navigationBar.sizeToFit()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        var searchPredicate: NSCompoundPredicate {
            let shortName = NSPredicate(format: "shortName BEGINSWITH[cd] %@", searchText)
            let fullName = NSPredicate(format: "fullName CONTAINS[cd] %@", searchText)
            let searchName = NSPredicate(format: "searchName CONTAINS[cd] %@", searchText)
            return NSCompoundPredicate(type: .or, subpredicates: [shortName, fullName, searchName])
        }
        var searchCompoundPredicate: NSCompoundPredicate {
            let additionalPredicate = NSPredicate(format: "isForCurrencyScreen == YES")
            return NSCompoundPredicate(type: .and, subpredicates: [searchPredicate, additionalPredicate])
        }
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: searchCompoundPredicate)
    }
}
