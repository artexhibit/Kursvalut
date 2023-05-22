
import UIKit

class NumpadView: UIView, UIInputViewAudioFeedback {
    
    @IBOutlet weak var resetButton: NumpadButton!
    @IBOutlet weak var decimalButton: NumpadButton!
    @IBOutlet weak var deleteButton: NumpadButton!
    
    private var keyboardWithSound: Bool {
        return UserDefaults.standard.bool(forKey: "keyboardWithSound")
    }
    private var target: UITextInput?
    private var view: UIView?
    var enableInputClicksWhenVisible: Bool {
        return keyboardWithSound ? true : false
    }
    private var decimalSeparator: String {
        return Locale.current.decimalSeparator ?? "."
    }
    private let resetButtonTitle = (pressed: "AC", inAction: "C")
    
    init(target: UITextInput, view: UIView) {
        super.init(frame: .zero)
        self.target = target
        self.view = view
        initializeSubview()
        setupDecimalButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeSubview()
        setupDecimalButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if UIDevice.current.userInterfaceIdiom == .phone {
            roundKeyboardCorners()
        }
    }
    
    private func setupDecimalButton() {
        decimalButton.setTitle(decimalSeparator, for: .normal)
    }
    
    private func initializeSubview() {
        let xibFileName = "NumpadView"
        let view = Bundle.main.loadNibNamed(xibFileName, owner: self, options: nil)![0] as! UIView
        self.addSubview(view)
        view.frame = self.bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    private func roundKeyboardCorners() {
        guard let superview = superview else { return }
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 25, height: 25))
        maskLayer.path = path.cgPath
        superview.layer.mask = maskLayer
    }
    
    @IBAction func numberButtonPressed(_ sender: NumpadButton) {
        insertText((sender.titleLabel!.text)!)
        resetButton.setTitle(resetButtonTitle.inAction, for: .normal)
    }
    
    @IBAction func decimalPressed(_ sender: NumpadButton) {
        insertText(decimalSeparator)
    }
    
    @IBAction func deleteButtonPressed(_ sender: NumpadButton) {
        target?.deleteBackward()
        insertText("D")
        
        if let textField = target as? UITextField, textField.text?.count == 0 {
            resetButton.setTitle(resetButtonTitle.pressed, for: .normal)
        }
    }
    
    @IBAction func hideKeyboardButtonPressed(_ sender: NumpadButton) {
        view?.endEditing(true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hideKeyboardButtonPressed"), object: nil)
    }
    
    @IBAction func resetButtonPressed(_ sender: NumpadButton) {
        if let textField = target as? UITextField {
            textField.text?.removeAll()
            insertText("C")
        }
        resetButton.setTitle(resetButtonTitle.pressed, for: .normal)
    }
    
    @IBAction func plusButtonPressed(_ sender: NumpadButton) {
        insertText("+")
    }
    
    @IBAction func minusButtonPressed(_ sender: NumpadButton) {
        insertText("-")
    }
    
    @IBAction func devideButtonPressed(_ sender: NumpadButton) {
        insertText("÷")
    }
    
    
    @IBAction func multiplyButtonPressed(_ sender: NumpadButton) {
        insertText("x")
    }
    
    @IBAction func equalButtonPressed(_ sender: NumpadButton) {
        insertText("=")
    }
    
    func insertText(_ string: String) {
        guard let range = target?.selectedRange else { return }
        if let textField = target as? UITextField, textField.delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) == false {
            return
        }
        target?.insertText(string)
    }
}

extension UITextInput {
    var selectedRange: NSRange? {
        guard let selectedRange = selectedTextRange else { return nil }
        let location = offset(from: beginningOfDocument, to: selectedRange.start)
        let length = offset(from: selectedRange.start, to: selectedRange.end)
        return NSRange(location: location, length: length)
    }
}
