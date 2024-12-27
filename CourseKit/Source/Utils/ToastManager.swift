import UIKit
import Foundation

public class ToastManager {
    public static let shared = ToastManager()
    
    private init() {}
    
    public func show(message: String) {
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else { return }

        let toastLabel = createToastLabel(message: message)
        positionToastLabel(toastLabel, in: window)
        animateToast(toastLabel, in: window)
    }
    
    private func createToastLabel(message: String) -> UILabel {
        let label = UILabel()
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = message
        label.alpha = 0
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.numberOfLines = 0
        return label
    }
    
    private func positionToastLabel(_ label: UILabel, in window: UIWindow) {
        let maxSize = CGSize(width: window.frame.size.width - 40, height: 100)
        var expectedSize = label.sizeThatFits(maxSize)
        expectedSize.width += 20
        expectedSize.height += 20
        
        label.frame = CGRect(
            x: window.frame.size.width/2 - expectedSize.width/2,
            y: window.frame.size.height - expectedSize.height - 100,
            width: expectedSize.width,
            height: expectedSize.height
        )
    }
    
    private func animateToast(_ label: UILabel, in window: UIWindow) {
        window.addSubview(label)
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            label.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 1.5, options: .curveEaseOut, animations: {
                label.alpha = 0
            }, completion: { _ in
                label.removeFromSuperview()
            })
        })
    }
} 
