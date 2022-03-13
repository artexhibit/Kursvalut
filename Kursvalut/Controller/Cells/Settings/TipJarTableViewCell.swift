
import UIKit

class TipJarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tipView: UIView!
    @IBOutlet weak var tipNameLabel: UILabel!
    @IBOutlet weak var tipPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipView.layer.cornerRadius = 8
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
