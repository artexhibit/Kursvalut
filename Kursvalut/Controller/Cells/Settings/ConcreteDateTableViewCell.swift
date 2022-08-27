
import UIKit

class ConcreteDateTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarIconBackground: UIView!
    @IBOutlet weak var dateSpinner: UIActivityIndicatorView!
    @IBOutlet weak var pickDateSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var proLabel: UIView!
    
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        proLabel.layer.cornerRadius = 3.0
        calendarIconBackground.layer.cornerRadius = 6
        calendarIconBackground.backgroundColor = UIColor(named: appColor)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
