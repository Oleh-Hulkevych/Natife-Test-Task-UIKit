//
//  PostTableViewCell.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit

protocol PostTableViewCellDelegate: AnyObject {
    func expandButtonTapped(inPost postId: Int)
    func likeButtonTapped(inPost postId: Int)
}

final class PostTableViewCell: UITableViewCell {

    // MARK: UI Elements
    
    private lazy var postTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .softBlack
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var postDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .softGray
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var likeButton: LikeButton = {
        let button = LikeButton()
        button.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var timestampLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .softGray
        label.textAlignment = .right
        return label
    }()
    
    private lazy var expandButton: HighlightedButton = {
        let button = HighlightedButton()
        button.backgroundColor = .softBlack
        button.layer.cornerRadius = 10
        button.setTitle("Expand", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(expandButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var postStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var postFooterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        return stackView
    }()
    
    // MARK: Properties & initialization
    
    static let reusableID = "PostTableViewCell"
    weak var delegate: PostTableViewCellDelegate?
    private var postId: Int?
    private var isCellExpanded = false {
        didSet {
            updateUIOnCellExpansion()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Cell state configurations
    
    func setPost(with post: FeedPost, isLiked: Bool) {
        postId = post.postId
        postTitleLabel.text = post.title
        postDescriptionLabel.text = post.previewText
        timestampLabel.text = post.timeshamp.timeAgoToString
        
        let likesCount = post.likesCount + (isLiked ? 1 : 0)
        likeButton.updateLike(isLiked: isLiked, likes: likesCount)
    }
    
    func setState(with state: PostCellStateModel) {
        isCellExpanded = state.isExpanded
        expandButton.isHidden = state.shouldHideButton
    }
    
    // MARK: Action configurations
    
    @objc
    private func expandButtonTapped() {
        isCellExpanded.toggle()
        guard let postId else { return }
        delegate?.expandButtonTapped(inPost: postId)
    }
    
    private func updateUIOnCellExpansion() {
        expandButton.setTitle(isCellExpanded ? "Collapse" : "Expand", for: .normal)
        postDescriptionLabel.numberOfLines = isCellExpanded ? 0 : 2
    }
    
    @objc
    private func likeButtonTapped() {
        guard let postId else { return }
        delegate?.likeButtonTapped(inPost: postId)
    }
    
    // MARK: Theme configurations
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        themeStyleDidChange()
    }
    
    private func themeStyleDidChange() {
        let interfaceStyle = traitCollection.userInterfaceStyle
        if interfaceStyle == .light {
            postTitleLabel.textColor = .softBlack
        } else {
            postTitleLabel.textColor = .softBlue
        }
    }
    
    // MARK: Auto Layout
    
    private func setupUI() {
        let titleContainerView = UIView()
        let descriptionContainerView = UIView()
        let timestampContainerView = UIView()
        
        titleContainerView.addSubview(postTitleLabel)
        descriptionContainerView.addSubview(postDescriptionLabel)
        contentView.addSubview(postStackView)
        timestampContainerView.addSubview(timestampLabel)
        [titleContainerView, descriptionContainerView, postFooterStackView, expandButton].forEach {
            postStackView.addArrangedSubview($0)
        }
        [likeButton, timestampContainerView].forEach {
            postFooterStackView.addArrangedSubview($0)
        }
        
        postTitleLabel.anchor(
            top: titleContainerView.topAnchor,
            leading: titleContainerView.leadingAnchor,
            bottom: titleContainerView.bottomAnchor,
            trailing: titleContainerView.trailingAnchor,
            padding: .init(top: 0, left: 10, bottom: 0, right: 10)
        )
        
        postDescriptionLabel.anchor(
            top: descriptionContainerView.topAnchor,
            leading: descriptionContainerView.leadingAnchor,
            bottom: descriptionContainerView.bottomAnchor,
            trailing: descriptionContainerView.trailingAnchor,
            padding: .init(top: 0, left: 10, bottom: 0, right: 10)
        )
        
        postStackView.anchor(
            top: self.contentView.topAnchor,
            leading: self.contentView.leadingAnchor,
            bottom: self.contentView.bottomAnchor,
            trailing: self.contentView.trailingAnchor,
            padding: .init(top: 15, left: 15, bottom: 5, right: 15)
        )

        timestampLabel.anchor(
            top: timestampContainerView.topAnchor,
            bottom: timestampContainerView.bottomAnchor, 
            trailing: timestampContainerView.trailingAnchor,
            padding: .init(top: 0, left: 0, bottom: 0, right: 10)
        )
        
        expandButton.anchor(
            leading: postStackView.leadingAnchor,
            trailing: postStackView.trailingAnchor,
            size: .init(width: 0, height: 44)
        )
        
        postStackView.setCustomSpacing(5, after: titleContainerView)
    }
}
