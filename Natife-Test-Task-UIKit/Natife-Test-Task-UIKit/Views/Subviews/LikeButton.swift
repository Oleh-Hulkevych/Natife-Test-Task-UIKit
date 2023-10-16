//
//  LikeButton.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit

final class LikeButton: UIButton {
    
    private lazy var heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "heart.fill")
        imageView.tintColor = .red
        return imageView
    }()
    
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .softGray
        return label
    }()
    
    private lazy var likesStackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLike(isLiked: Bool, likes: Int) {
        if isLiked {
            heartImageView.image = UIImage(systemName: "heart.fill")
        } else {
            heartImageView.image = UIImage(systemName: "heart")
        }
        likesLabel.text = "\(likes)"
    }
    
    private func configureLayout() {
        self.anchor(size: .init(width: 44, height: 44))
        
        addSubview(likesStackViewContainer)
        likesStackViewContainer.anchor(
            top: self.topAnchor,
            leading: self.leadingAnchor,
            bottom: self.bottomAnchor,
            padding: .init(top: 0, left: 10, bottom: 0, right: 0)
        )
        
        [heartImageView, likesLabel].forEach {
            likesStackViewContainer.addArrangedSubview($0)
        }
        
        heartImageView.anchor(
            top: likesStackViewContainer.topAnchor,
            bottom: likesStackViewContainer.bottomAnchor,
            size: .init(width: 20, height: 0)
        )
    }
}
