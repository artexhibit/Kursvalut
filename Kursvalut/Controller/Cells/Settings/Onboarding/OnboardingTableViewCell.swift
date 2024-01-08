
import UIKit

class OnboardingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tableImage: UIImageView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var openTutorialButton: UIButton!
    @IBOutlet weak var openTutorialIconButton: UIButton!
    
    var openOnboardingAction: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        setupShadowView()
        openTutorialButton.tintColor = UIColor(named: "\(UserDefaultsManager.appColor)")
        openTutorialButton.addTarget(self, action: #selector(openTutorialButtonPressed(_:)), for: .touchUpInside)
        openTutorialIconButton.addTarget(self, action: #selector(openTutorialButtonPressed(_:)), for: .touchUpInside)
  }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func openTutorialButtonPressed(_ sender: UIButton) {
        openOnboardingAction?()
    }
    
    private func setupShadowView() {
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 20
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -15)
        shadowView.layer.cornerRadius = 30
    }

}
