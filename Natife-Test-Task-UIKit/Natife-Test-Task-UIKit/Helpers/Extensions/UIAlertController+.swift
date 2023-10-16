//
//  UIAlertController+.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 13.10.2023.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String?, message: String?, cancelButtonTitle: String? = nil, actionButtonTitle: String? = nil, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let actionButtonTitle = actionButtonTitle {
            let actionAction = UIAlertAction(title: actionButtonTitle, style: .default) { _ in
                action?()
            }
            alert.addAction(actionAction)
        }

        if let cancelButtonTitle = cancelButtonTitle {
            let okAction = UIAlertAction(title: cancelButtonTitle, style: .default) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
        }

        present(alert, animated: true, completion: nil)
    }
}
