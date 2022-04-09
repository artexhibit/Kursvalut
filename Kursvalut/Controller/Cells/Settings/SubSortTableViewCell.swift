
import UIKit

class SubSortTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    var isPressed = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
