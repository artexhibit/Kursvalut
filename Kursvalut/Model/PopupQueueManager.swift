import UIKit

final class PopupQueueManager {
    static let shared = PopupQueueManager()
    init() {}
    
    var popupViewsData = [(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType)]()
    var hasDisplayingPopup = false
    var currentPopup: PopupView?
    
    func addPopupToQueue(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType = .auto) {
        DispatchQueue.main.async {
            if !self.popupViewsData.isEmpty && type == .manual {
                self.currentPopup!.hidePopup(animationDuration: 0.1)
            }
            self.popupViewsData.append((title: title, message: message, style: style, type: type))
            let popup = PopupView()
            self.currentPopup = popup
            self.showNextPopupView()
        }
    }
    
    func showNextPopupView() {
        DispatchQueue.main.async {
            guard !self.popupViewsData.isEmpty && !self.hasDisplayingPopup else { return }
            self.hasDisplayingPopup = true
            
            if let currentPopup = self.currentPopup, let popupData = self.popupViewsData.first {
                currentPopup.showPopup(title: popupData.title, message: popupData.message, style: popupData.style, type: popupData.type)
            }
        }
    }
    
    func changePopupDataInQueue(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType = .auto) {
        DispatchQueue.main.async {
            if self.hasDisplayingPopup {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    if let currentPopup = self.currentPopup {
                        currentPopup.changePopupData(title: title, message: message, style: style, type: type)
                    }
                }
            }
        }
    }
}
