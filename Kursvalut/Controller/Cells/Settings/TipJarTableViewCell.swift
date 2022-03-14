
import UIKit

class TipJarTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tipButton: UIButton!
    @IBOutlet weak var tipNameLabel: UILabel!
    @IBOutlet weak var tipPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tipButton.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
