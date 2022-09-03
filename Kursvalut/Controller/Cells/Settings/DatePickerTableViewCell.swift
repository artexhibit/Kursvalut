
import UIKit

class DatePickerTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var resetDateButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    let minimumDate = Date(timeIntervalSinceReferenceDate: -31622400.0)
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
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
