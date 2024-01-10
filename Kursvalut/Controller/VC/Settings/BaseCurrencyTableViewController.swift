
import UIKit
import CoreData

class BaseCurrencyTableViewController: UITableViewController {
    
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var currencyManager = CurrencyManager()
    private var coreDataManager = CurrencyCoreDataManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupSearchController()
        tableView.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
    
    // MARK: - TableView Delegate & DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return forexFRC.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return forexFRC.sections![section].name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sectionTitles = [String]()
        
        guard let sections = forexFRC?.sections else { return nil }
        
        for section in sections {
            guard let firstCharacter = section.name.first else { return nil }
            sectionTitles.append(String(firstCharacter))
        }
        return sectionTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return forexFRC.section(forSectionIndexTitle: title, at: index)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forexFRC.sections![section].numberOfObjects
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "baseCurrencyCell", for: indexPath) as! BaseCurrencyTableViewCell
        
        let currency = forexFRC.object(at: indexPath)
        cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
        cell.shortName.text = currency.shortName
        cell.fullName.text = currency.fullName
        cell.picker.image = currency.shortName == UserDefaultsManager.baseCurrency ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! BaseCurrencyTableViewCell
        let forexCurrency = forexFRC.object(at: indexPath)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchController.isActive = false
        }
        UserDefaultsManager.baseCurrency = forexCurrency.shortName ?? ""
        cell.picker.image = forexCurrency.shortName == UserDefaultsManager.baseCurrency ? UIImage(systemName: "checkmark.circle.fill") : UIImage(systemName: "circle")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDataFromDataSourceVC"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshBaseCurrency"), object: nil)
        
        if UserDefaultsManager.pickedDataSource == "ЦБ РФ" {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().cbrf)
        } else {
            coreDataManager.assignRowNumbers(to: coreDataManager.fetchSortedCurrencies().forex)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.dismiss(animated: true)
        }
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension BaseCurrencyTableViewController: NSFetchedResultsControllerDelegate {
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
        forexFRC = coreDataManager.createForexCurrencyFRC(with: searchCompoundPredicate, and: sortDescriptor)
        forexFRC.delegate = self
        try? forexFRC.performFetch()
        
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

extension BaseCurrencyTableViewController: UISearchResultsUpdating {
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по коду и имени валюты"
        definesPresentationContext = true
        navigationItem.searchController = searchController
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
