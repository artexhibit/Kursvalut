
import UIKit

class DatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var resetDateButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    private let currencyCoreDataManager = CurrencyCoreDataManager()
    private var appColor: String {
        return UserDefaults.sharedContainer.string(forKey: "appColor") ?? ""
    }
    private var pickedDataSource: String {
        return UserDefaults.sharedContainer.string(forKey: "baseSource") ?? ""
    }
    let minimumDate = Date(timeIntervalSinceReferenceDate: -31622400.0)
    private var maximumDate: Date {
        if pickedDataSource == "ЦБ РФ" {
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
        datePicker.tintColor = UIColor(named: appColor)
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()
        
        if #available(iOS 14.0, *) {
            datePicker.preferredDatePickerStyle = .inline
        }
    }
    
    func setupButtons() {
        resetDateButton.tintColor = UIColor(named: appColor)
        confirmButton.tintColor = UIColor(named: appColor)
    }
}
