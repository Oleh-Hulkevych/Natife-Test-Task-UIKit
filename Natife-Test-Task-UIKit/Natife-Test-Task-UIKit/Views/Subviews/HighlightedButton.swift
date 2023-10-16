//
//  HighlightedButton.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit

final class HighlightedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = isHighlighted ? 0.4 : 1
        }
    }
}
