
import UIKit

class CustomSortTableViewCell: UITableViewCell {

    @IBOutlet weak var proLabel: UIView!
    @IBOutlet weak var customSortSwitch: UISwitch!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        proLabel.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
