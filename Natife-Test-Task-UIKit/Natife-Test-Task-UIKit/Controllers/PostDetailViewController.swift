//
//  PostDetailViewController.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit
import SDWebImage

protocol PostDetailViewControllerDelegate: AnyObject {
    func likebuttonTapped(inPost postId: Int)
}

final class PostDetailViewController: UIViewController {
    
    // MARK: UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var contentView = UIView()
    
    private lazy var postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var postInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()
    
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
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var postFooterStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isHidden = true
        return stackView
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
    
    private lazy var scrollViewRefreshControl = UIRefreshControl()
    
    // MARK: Properties & initialization
    
    weak var delegate: PostDetailViewControllerDelegate?
    private var post: PostInfo?
    private let postId: Int
    private let networkManager: NetworkManager
    private let likesManager: LikesManager
    private var postImageViewHeightConstraint: NSLayoutConstraint?
    
    init(postId: Int, networkManager: NetworkManager, likesManager: LikesManager) {
        self.postId = postId
        self.networkManager = networkManager
        self.likesManager = likesManager
        super.init(nibName: nil, bundle: nil)
        fetchPost(id: postId)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeStyle()
        configureNavigationBar()
        setupUI()
        configureRefreshControl()
        themeStyle()
    }
    
    // MARK: Network methods
    
    private func fetchPost(id postId: Int) {
        networkManager.wrapOnBackground({ completion in
            self.networkManager.fetchPostById(postId: postId) { result in
                completion(result)
            }
        }) { result in
            switch result {
            case .success(let post):
                self.post = post
                self.updatePostDetails(with: post)
            case .failure(let error):
                self.showAlert(title: "Ups!", message: error.localizedDescription, actionButtonTitle: "Retry?") {
                    self.fetchPost(id: postId)
                }
            }
        }
    }
    
    private func fetchImage(withUrl url: URL) {
        let imagePlaceholder = UIImage(named: "image.placeholder")
        let options: SDWebImageOptions = [.continueInBackground]
        postImageView.sd_setImage(with: url, placeholderImage: imagePlaceholder, options: options) { [weak self] (image, error, cacheType, _) in
            guard let self = self else { return }
            if let error {
                print(error.localizedDescription)
            } else {
                if let image {
                    let animate = cacheType != .memory
                    DispatchQueue.main.async {
                        self.postImageView.image = image
                        self.matchPostImageViewHeight(withImage: image, animate: animate)
                    }
                }
            }
        }
    }
    
    // MARK: Configure UI
    
    private func configureNavigationBar() {
        navigationItem.title = "Post Info"
    }
    
    private func configureRefreshControl() {
        scrollViewRefreshControl.addTarget(self, action: #selector(refreshControlDidDrag), for: .valueChanged)
        scrollView.refreshControl = scrollViewRefreshControl
    }
    
    @objc
    private func refreshControlDidDrag() {
        fetchPost(id: postId)
        self.perform(#selector(refreshControlDidFinishRefreshing), with: nil, afterDelay: 1)
    }
    
    @objc
    private func refreshControlDidFinishRefreshing() {
        scrollViewRefreshControl.endRefreshing()
    }
    
    // MARK: Update UI methods
    
    private func updatePostDetails(with post: PostInfo) {
        fetchImage(withUrl: post.postImage)
        postTitleLabel.text = post.title
        postDescriptionLabel.text = post.text
        timestampLabel.text = post.timeshamp.timeAgoToString
        updateLikes(inPost: post)
        postFooterStackView.isHidden = false
    }
    
    private func matchPostImageViewHeight(withImage image: UIImage, animate: Bool) {
        guard let screenWidth = UIScreen.current?.bounds.width else { return }
        let scale = screenWidth / image.size.width
        let imageViewHeight = image.size.height * scale
        postImageViewHeightConstraint?.constant = imageViewHeight
        if animate {
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc
    private func likeButtonTapped() {
        guard let post else { return }
        delegate?.likebuttonTapped(inPost: post.postId)
        likesManager.togglePostLike(id: post.postId)
        updateLikes(inPost: post)
    }
    
    private func updateLikes(inPost post: PostInfo) {
        let isLiked = likesManager.isLikedPost(id: post.postId)
        let likesCount = post.likesCount + (isLiked ? 1 : 0)
        likeButton.updateLike(isLiked: isLiked, likes: likesCount)
    }
    
    // MARK: Theme configurations
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        themeStyle()
    }
    
    private func themeStyle() {
        let interfaceStyle = traitCollection.userInterfaceStyle
        if interfaceStyle == .light {
            view.backgroundColor = .white
            postTitleLabel.textColor = .softBlack
            scrollViewRefreshControl.tintColor = .softBlack
        } else {
            view.backgroundColor = .black
            postTitleLabel.textColor = .softBlue
            scrollViewRefreshControl.tintColor = .softBlue
        }
    }
    
    // MARK: Auto Layout
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.pin(to: self.view)
        
        scrollView.addSubview(contentView)
        contentView.pin(to: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        contentView.addSubview(postImageView)
        postImageView.anchor(
            top: contentView.topAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor
        )
        postImageViewHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: view.bounds.height / 2)
        postImageViewHeightConstraint?.isActive = true
        
        contentView.addSubview(postInfoStackView)
        postInfoStackView.anchor(
            top: postImageView.bottomAnchor,
            leading: contentView.leadingAnchor,
            trailing: contentView.trailingAnchor,
            padding: .init(top: 15, left: 20, bottom: 0, right: 20)
        )
        [postTitleLabel, postDescriptionLabel].forEach {
            postInfoStackView.addArrangedSubview($0)
        }
        
        contentView.addSubview(postFooterStackView)
        postFooterStackView.anchor(
            top: postInfoStackView.bottomAnchor,
            leading: contentView.leadingAnchor,
            bottom: contentView.bottomAnchor,
            trailing: contentView.trailingAnchor,
            padding: .init(top: 5, left: 10, bottom: 30, right: 23)
        )
        
        [likeButton, timestampLabel].forEach {
            postFooterStackView.addArrangedSubview($0)
        }
        
        postInfoStackView.setCustomSpacing(15, after: postTitleLabel)
    }
}
