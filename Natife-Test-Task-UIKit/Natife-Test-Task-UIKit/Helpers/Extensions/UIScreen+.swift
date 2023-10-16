//
//  UIScreen+.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 10.10.2023.
//

import UIKit

extension UIScreen {
    
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
}

private extension UIWindow {
    
    static var current: UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                if window.isKeyWindow { return window }
            }
        }
        return nil
    }
}
