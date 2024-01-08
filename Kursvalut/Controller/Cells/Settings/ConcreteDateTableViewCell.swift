
import UIKit

class ConcreteDateTableViewCell: UITableViewCell {

    @IBOutlet weak var calendarIconBackground: UIView!
    @IBOutlet weak var dateSpinner: UIActivityIndicatorView!
    @IBOutlet weak var pickDateSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var proLabel: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        proLabel.layer.cornerRadius = 3.0
        calendarIconBackground.layer.cornerRadius = 6
        calendarIconBackground.backgroundColor = UIColor(named: UserDefaultsManager.appColor)
        dateLabel.textColor = UIColor(named: UserDefaultsManager.appColor)
        dateSpinner.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
