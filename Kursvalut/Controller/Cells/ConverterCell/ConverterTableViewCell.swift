
import UIKit

class ConverterTableViewCell: UITableViewCell {

    @IBOutlet weak var flag: UIImageView!
    @IBOutlet weak var shortName: UILabel!
    @IBOutlet weak var numberTextField: UITextField!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var activityIndicator: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupActivityIndicator()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupActivityIndicator() {
        activityIndicator.layer.cornerRadius = activityIndicator.bounds.size.width / 2
        activityIndicator.layer.borderWidth = 1.5
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        activityIndicator.layer.borderColor = UIColor(named: "ActivityIndicatorColor")?.cgColor
    }
}
