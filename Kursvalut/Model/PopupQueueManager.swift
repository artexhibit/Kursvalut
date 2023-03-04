import UIKit

class PopupQueueManager {
    static let shared = PopupQueueManager()
    init() {}
    
    var popupViewsData = [(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType)]()
    var hasDisplayingPopup = false
    var currentPopup: PopupView?
    
    func addPopupToQueue(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType = .auto) {
        if !popupViewsData.isEmpty && type == .manual {
            currentPopup!.hidePopup(animationDuration: 0.1)
        }
        popupViewsData.append((title: title, message: message, style: style, type: type))
        let popup = PopupView()
        currentPopup = popup
        showNextPopupView()
    }
    
    func showNextPopupView() {
        guard !popupViewsData.isEmpty && !hasDisplayingPopup else { return }
        hasDisplayingPopup = true
        
        if let currentPopup = currentPopup, let popupData = popupViewsData.first {
                currentPopup.showPopup(title: popupData.title, message: popupData.message, style: popupData.style, type: popupData.type)
        }
    }
    
    func changePopupDataInQueue(title: String, message: String, style: PopupView.PopupStyle, type: PopupView.BehaviourType = .auto) {
        if hasDisplayingPopup {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if let currentPopup = self.currentPopup {
                    currentPopup.changePopupData(title: title, message: message, style: style, type: type)
                }
            }
        }
    }
}
