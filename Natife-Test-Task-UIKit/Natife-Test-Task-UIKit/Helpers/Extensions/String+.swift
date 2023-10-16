//
//  String+.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit

extension String {
    
    func minimumLines(thatFitsWidth width: CGFloat, font: UIFont) -> Int {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let textSize = (self as NSString).boundingRect(
            with: maxSize,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return Int(ceil(CGFloat(textSize.height) / font.lineHeight))
    }
}
