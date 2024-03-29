
import UIKit

protocol StepperDelegate {
    func stepperWasPressed(cell: UITableViewCell, number: Int)
}

class DecimalsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var delegate: StepperDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func stepperPressed(_ sender: UIStepper) {
        numberLabel.text = Int(sender.value).description
        delegate?.stepperWasPressed(cell: self, number: Int(sender.value))
    }
}
