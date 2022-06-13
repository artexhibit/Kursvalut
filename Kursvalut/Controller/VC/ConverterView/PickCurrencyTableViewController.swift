
import UIKit
import CoreData

class PickCurrencyTableViewController: UITableViewController {
    
    private var bankOfRussiaFRC: NSFetchedResultsController<Currency>!
    private var forexFRC: NSFetchedResultsController<ForexCurrency>!
    private let searchController = UISearchController(searchResultsController: nil)
    private var currencyManager = CurrencyManager()
    private let coreDataManager = CurrencyCoreDataManager()
    private let converterManager = ConverterManager()
    private var proPurchased: Bool {
        return UserDefaults.standard.bool(forKey: "kursvalutPro")
    }
    private var pickedDataSource: String {
        return UserDefaults.standard.string(forKey: "baseSource") ?? ""
    }
    private var amountOfPickedBankOfRussiaCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForBankOfRussia")
    }
    private var amountOfPickedForexCurrencies: Int {
        return UserDefaults.standard.integer(forKey: "savedAmountForForex")
    }
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
        setupSearchController()
        tableView.tintColor = UIColor(named: "\(appColor)")
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    // MARK: - TableView Delegate & DataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections!.count : forexFRC.sections!.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].name : forexFRC.sections![section].name
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        var sectionTitles = [String]()
        
        if pickedDataSource == "ЦБ РФ" {
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
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.section(forSectionIndexTitle: title, at: index) : forexFRC.section(forSectionIndexTitle: title, at: index)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickedDataSource == "ЦБ РФ" ? bankOfRussiaFRC.sections![section].numberOfObjects : forexFRC.sections![section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pickCurrencyCell", for: indexPath) as! PickCurrencyTableViewCell
        
        if pickedDataSource == "ЦБ РФ" {
            let currency = bankOfRussiaFRC.object(at: indexPath)
            
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.picker.image = currency.isForConverter ? UIImage(named: "checkmark.circle.fill") : UIImage(named: "circle")
        } else {
            let currency = forexFRC.object(at: indexPath)
            
            cell.flag.image = currencyManager.showCurrencyFlag(currency.shortName ?? "notFound")
            cell.shortName.text = currency.shortName
            cell.fullName.text = currency.fullName
            cell.picker.image = currency.isForConverter ? UIImage(named: "checkmark.circle.fill") : UIImage(named: "circle")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if pickedDataSource == "ЦБ РФ" {
            var currentAmount = amountOfPickedBankOfRussiaCurrencies
            let bankOfRussiaCurrencies = coreDataManager.fetchAllBankOfRussiaCurrencies()
            let bankOfRussiaCurrency = bankOfRussiaFRC.object(at: indexPath)
            
            bankOfRussiaCurrency.isForConverter = !bankOfRussiaCurrency.isForConverter
            bankOfRussiaCurrency.isForConverter ? (currentAmount += 1) : (currentAmount -= 1)
            
            if proPurchased {
                converterManager.setRow(for: bankOfRussiaCurrency, in: bankOfRussiaCurrencies)
            } else if !proPurchased && currentAmount <= 3 {
                converterManager.setRow(for: bankOfRussiaCurrency, in: bankOfRussiaCurrencies)
                UserDefaults.standard.set(currentAmount, forKey: "savedAmountForBankOfRussia")
            } else {
                bankOfRussiaCurrency.isForConverter = false
                currentAmount -= 1
                UserDefaults.standard.set(currentAmount, forKey: "savedAmountForBankOfRussia")
                PopupView().showPopup(title: "Максимум 3 валюты", message: "Безлимитно в Pro", type: .lock)
            }
        } else {
            var currentAmount = amountOfPickedForexCurrencies
            let forexCurrencies = coreDataManager.fetchAllForexCurrencies()
            let forexCurrency = forexFRC.object(at: indexPath)
            
            forexCurrency.isForConverter = !forexCurrency.isForConverter
            forexCurrency.isForConverter ? (currentAmount += 1) : (currentAmount -= 1)
            
            if proPurchased {
                converterManager.setRow(for: forexCurrency, in: forexCurrencies)
            } else if !proPurchased && currentAmount <= 3 {
                converterManager.setRow(for: forexCurrency, in: forexCurrencies)
                UserDefaults.standard.set(currentAmount, forKey: "savedAmountForForex")
            } else {
                forexCurrency.isForConverter = false
                currentAmount -= 1
                UserDefaults.standard.set(currentAmount, forKey: "savedAmountForForex")
                PopupView().showPopup(title: "Максимум 3 валюты", message: "Безлимитно в Pro", type: .lock)
            }
        }
        coreDataManager.save()
    }
}

//MARK: - NSFetchedResultsController Setup & Delegates

extension PickCurrencyTableViewController: NSFetchedResultsControllerDelegate {
    func setupFetchedResultsController(with searchPredicate: NSPredicate? = nil) {
        if pickedDataSource == "ЦБ РФ" {
            UserDefaults.standard.set(true, forKey: "pickCurrencyRequest")
            let sortDescriptor = NSSortDescriptor(key: "fullName", ascending: true)
            bankOfRussiaFRC = coreDataManager.createBankOfRussiaCurrencyFRC(with: searchPredicate, and: sortDescriptor)
            bankOfRussiaFRC.delegate = self
            try? bankOfRussiaFRC.performFetch()
        } else {
            UserDefaults.standard.set(true, forKey: "pickCurrencyRequest")
            let sortDescriptor = NSSortDescriptor(key: "fullName", ascending: true)
            forexFRC = coreDataManager.createForexCurrencyFRC(with: searchPredicate, and: sortDescriptor)
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
        searchController.searchBar.placeholder = "Поиск"
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
        searchText.count == 0 ? setupFetchedResultsController() : setupFetchedResultsController(with: searchPredicate)
    }
}
