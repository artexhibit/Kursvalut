
import UIKit

protocol UIDatePickerDelegate {
    func didPickedDateFromPicker(_ datePickerView: DatePickerView, pickedDate: String, lastConfirmedDate: String)
}

class DatePickerView: UIView {
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var cornerView: UIView!
    
    var delegate: UIDatePickerDelegate?
    private var pickedDate: String?
    private let currencyManager = CurrencyManager()
    private let minimumDate = Date(timeIntervalSinceReferenceDate: -31622400.0)
    private var appColor: String {
        return UserDefaults.standard.string(forKey: "appColor") ?? ""
    }
    private var todaysDate: String {
        return currencyManager.createStringDate(with: "dd.MM.yyyy", from: Date(), dateStyle: .medium)
    }
    private var confirmedDate: String {
        return UserDefaults.standard.string(forKey: "confirmedDate") ?? ""
    }
    private var interfaceOrientation: UIInterfaceOrientation {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .unknown }
        let interfaceOrientation = windowScene.interfaceOrientation
        return interfaceOrientation
    }
    private var lastConfirmedDate: String?
    private var widthConstraint: NSLayoutConstraint?
    private var viewSize: (width: CGFloat, height: CGFloat) = (0,0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        UserDefaults.standard.set(pickedDate, forKey: "confirmedDate")
        delegate?.didPickedDateFromPicker(self, pickedDate: pickedDate ?? "", lastConfirmedDate: lastConfirmedDate ?? "")
        hideView()
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        pickedDate = confirmedDate
        hideView()
    }
    
    @IBAction func datePickerPressed(_ sender: UIDatePicker) {
        let senderDate = currencyManager.createStringDate(with: "dd.MM.yyyy", from: sender.date, dateStyle: .medium)
        pickedDate = senderDate
        animateDoneButton()
    }
    
    private func configure() {
        if let views = Bundle.main.loadNibNamed("DatePickerView", owner: self) {
            guard let view = views.first as? UIView else { return }
            view.translatesAutoresizingMaskIntoConstraints = false
            addSubview(view)
            
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: topAnchor, constant: 0.0),
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0),
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            ])
        }
    }
    
    func showView(under button: UIButton, in view: UIView) {
        configureView(under: button, in: view)
        datePicker.date = currencyManager.createDate(from: confirmedDate)
        lastConfirmedDate = confirmedDate
        configureButtons()
        configureDatePicker()
        configureViewDesign()
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 2, options: .curveEaseOut) {
            self.alpha = 1.0
            self.transform = .identity
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.55, initialSpringVelocity: 2, options: .curveEaseOut) {
            self.alpha = 0.0
            self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        } completion: { [weak self] _ in
            guard let self = self else { return }
            self.removeFromSuperview()
        }
    }
    
    private func configureView(under button: UIButton, in view: UIView) {
        viewSize = getViewSize()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self)
        
        self.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 0).isActive = true
        self.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 10.0).isActive = true
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.widthAnchor.constraint(equalToConstant: 400.0).isActive = true
            self.heightAnchor.constraint(equalToConstant: 400.0).isActive = true
        } else {
            self.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: viewSize.height).isActive = true
            widthConstraint = self.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: viewSize.width)
            widthConstraint?.isActive = true
        }
        addOrientationObserver(in: view)
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func addOrientationObserver(in view: UIView) {
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] _ in
            guard let self = self else { return }
            guard self.superview != nil else { return }
            
            if UIDevice.current.userInterfaceIdiom == .phone {
                self.viewSize = self.getViewSize()
                self.widthConstraint?.isActive = false
                self.widthConstraint = self.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: self.viewSize.width)
                self.widthConstraint?.isActive = true
                self.datePicker.preferredDatePickerStyle = self.interfaceOrientation.isPortrait ? .inline : .wheels
            }
        }
    }
    
    private func getViewSize() -> (width: CGFloat, height: CGFloat) {
        if UIScreen().sizeType == .iPhoneSE {
            return interfaceOrientation.isPortrait ? (0.88, 0.55) : (0.55, 0.55)
        } else {
            return interfaceOrientation.isPortrait ? (0.75, 0.4) : (0.45, 0.4)
        }
    }
    
    private func animateDoneButton() {
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn) { [self] in
            if let dataForPickedDate = pickedDate, confirmedDate != dataForPickedDate {
                doneButton.alpha = 1.0
                doneButton.isUserInteractionEnabled = true
            } else {
                doneButton.alpha = 0.0
                doneButton.isUserInteractionEnabled = false
            }
        }
    }
    
    private func configureButtons() {
        cancelButton.tintColor = UIColor(named: appColor)
        doneButton.tintColor = UIColor(named: appColor)
        doneButton.alpha = 0.0
        doneButton.isUserInteractionEnabled = false
    }
    
    private func configureDatePicker() {
        datePicker.tintColor = UIColor(named: appColor)
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = Date()
        datePicker.preferredDatePickerStyle = interfaceOrientation.isPortrait ? .inline : .wheels
    }
    
    private func configureViewDesign() {
        self.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 6.0)
        self.layer.shadowRadius = 6.0
        self.layer.masksToBounds = false
        
        cornerView.layer.masksToBounds = true
        cornerView.clipsToBounds = true
        cornerView.layer.cornerRadius = 20
    }
}
