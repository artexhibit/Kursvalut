import UIKit

class NotificationPermissionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var permissionButton: UIButton!
    
    let descriptionText = "Приложение научилось показывать актуальные курсы валют, как только они публикуются. \n \nЧтобы вас можно было оповещать об изменении и загружать их, пожалуйста, разрешите уведомления. \n \nОни будут приходить один раз в день для каждого источника, не расходуя заряд устройства."
    
    override func awakeFromNib() {
        super.awakeFromNib()
        descriptionLabel.text = descriptionText
        permissionButton.layer.cornerRadius = 15
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
