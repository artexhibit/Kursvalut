
import UIKit

class DatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var resetDateButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    private let currencyCoreDataManager = CurrencyCoreDataManager()
    let minimumDate = Date(timeIntervalSinceReferenceDate: -31622400.0)
    private var maximumDate: Date {
        if UserDefaultsManager.pickedDataSource == CurrencyData.cbrf {
            let currentStoredDate = currencyCoreDataManager.fetchBankOfRussiaCurrenciesCurrentDate()
            if Date.isTomorrow(date: currentStoredDate) { return currentStoredDate }
            return Date.currentDate
        } else {
            return Date.currentDate
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDatePicker()
        setupButtons()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupDatePicker() {
        datePicker.tintColor = UIColor(named: UserDefaultsManager.appColor)
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
    }
    
    func setupButtons() {
        resetDateButton.tintColor = UIColor(named: UserDefaultsManager.appColor)
        confirmButton.tintColor = UIColor(named: UserDefaultsManager.appColor)
    }
}
