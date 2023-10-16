//
//  PostsTableViewController.swift
//  Natife-Test-Task-UIKit
//
//  Created by Hulkevych on 09.10.2023.
//

import UIKit

final class PostsTableViewController: UITableViewController {
    
    // MARK: UI Elements
    
    private lazy var sortBarBattonMenu = UIMenu()
    private lazy var tableFooterView = UIView()
    private lazy var tableViewRefreshControl = UIRefreshControl()
    
    private lazy var tableFooterTextLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .softGray
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    // MARK: Properties & initialization
    
    private let networkManager = NetworkManager()
    private let likeManager = LikesManager()
    private var posts = [FeedPost]()
    private var expandedCellsIDs: Set<Int> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSortButtonMenu()
        configureNavigationBar()
        configureTableView()
        configureTableViewFooter()
        configureRefreshControl()
        themeStyle()
        fetchPosts()
    }
    
    // MARK: Network methods
    
    private func fetchPosts() {
        networkManager.wrapOnBackground(networkManager.fetchPosts) { result in
            switch result {
            case .success(let posts):
                self.posts = posts
                self.showTableFooterView(posts: posts)
                self.tableView.reloadData()
            case .failure(let error):
                self.showAlert(title: "Ups!", message: error.localizedDescription, actionButtonTitle: "Retry?") {
                    self.fetchPosts()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // MARK: Table view data sources
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostTableViewCell.reusableID, for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        let post = posts[indexPath.row]
        let numberOfLines: Int = 2
        let expanded = expandedCellsIDs.contains(post.postId) ? 0 : numberOfLines
        let buttonHiden = hideElementsBasedOnTextLines(of: numberOfLines, of: post.previewText, withWidth: tableView.bounds.width)
        let state = PostCellStateModel(isExpanded: expanded, shouldHideButton: buttonHiden)
        cell.setPost(with: post, isLiked: likeManager.isLikedPost(id: post.postId))
        cell.setState(with: state)
        return cell
    }
    
    private func hideElementsBasedOnTextLines(of: Int, of text: String, withWidth width: CGFloat) -> Bool  {
        let font = UIFont.systemFont(ofSize: 16, weight: .medium)
        let numberOfLines = text.minimumLines(thatFitsWidth: width, font: font)
        let shouldHideButton = numberOfLines <= 2
        return shouldHideButton
    }
    
    // MARK: Table view delegates
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postId = posts[indexPath.row].postId
        let postDetailViewController = PostDetailViewController(postId: postId, networkManager: networkManager, likesManager: likeManager)
        postDetailViewController.delegate = self
        self.navigationController?.pushViewController(postDetailViewController, animated: true)
        self.tableView.deselectRow(at: indexPath, animated: true)
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
            navigationItem.rightBarButtonItem?.tintColor = .black
            tableViewRefreshControl.tintColor = .softBlack
        } else {
            view.backgroundColor = .black
            navigationItem.rightBarButtonItem?.tintColor = .white
            tableViewRefreshControl.tintColor = .softBlue
        }
    }
    
    // MARK: Configure UI
    
    private func configureNavigationBar() {
        navigationItem.title = "Posts"
        let sortImage = UIImage(systemName: "arrow.up.and.down.text.horizontal")
        let sortButton = UIBarButtonItem(image: sortImage, menu: sortBarBattonMenu)
        sortButton.tintColor = .black
        navigationItem.rightBarButtonItem = sortButton
    }
    
    private func configureSortButtonMenu() {
        let sortByDate = UIAction(title: "Date", image: UIImage(systemName: "calendar.circle")) { [weak self] _ in
            guard let self = self else { return }
            let sortedByDate = self.posts.sorted { $0.timeshamp > $1.timeshamp }
            self.posts = sortedByDate
            self.tableView.reloadData()
        }
        
        let sortByRating = UIAction(title: "Rating", image: UIImage(systemName: "heart.circle")) { [weak self] _ in
            guard let self = self else { return }
            let sortedByRating = self.posts.sorted { $0.likesCount > $1.likesCount }
            self.posts = sortedByRating
            self.tableView.reloadData()
        }
        
        sortBarBattonMenu = UIMenu(title: "Sort posts by:", children: [sortByDate, sortByRating])
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reusableID)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        tableView.separatorColor = UIColor.softGray
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.delaysContentTouches = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    private func configureTableViewFooter() {
        guard let screenWidth = UIScreen.current?.bounds.width else { return }
        tableFooterView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: 70)
        tableFooterView.addSubview(tableFooterTextLabel)
        tableFooterTextLabel.frame = tableFooterView.bounds
    }
    
    private func showTableFooterView(posts: [FeedPost]) {
        if !posts.isEmpty {
            self.tableView.tableFooterView = tableFooterView
            tableFooterTextLabel.text = "No more posts\n available."
        }
    }
    
    private func configureRefreshControl() {
        tableViewRefreshControl.addTarget(self, action: #selector(refreshControlDidDrag), for: .valueChanged)
        tableView.refreshControl = tableViewRefreshControl
    }
    
    @objc
    private func refreshControlDidDrag(send: UIRefreshControl) {
        fetchPosts()
        self.perform(#selector(refreshControlDidFinishRefreshing), with: nil, afterDelay: 1)
    }
    
    @objc
    private func refreshControlDidFinishRefreshing() {
        tableViewRefreshControl.endRefreshing()
    }
}

// MARK: - Post Cell delegates

extension PostsTableViewController: PostTableViewCellDelegate {
    func expandButtonTapped(inPost postId: Int) {
        if expandedCellsIDs.contains(postId) {
            expandedCellsIDs.remove(postId)
        } else {
            expandedCellsIDs.insert(postId)
        }
        updateCellUI()
        print("📘: Expanded cells at post IDs: \(expandedCellsIDs)")
    }
    
    func likeButtonTapped(inPost postId: Int) {
        likeManager.togglePostLike(id: postId)
        updateLikedCell(forPostId: postId)
    }
    
    private func updateLikedCell(forPostId postId: Int) {
        if let index = posts.firstIndex(where: { $0.postId == postId }),
           let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? PostTableViewCell {
            cell.setPost(with: posts[index], isLiked: likeManager.isLikedPost(id: postId))
        }
    }
    
    private func updateCellUI() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        tableView.beginUpdates()
        tableView.endUpdates()
        CATransaction.commit()
    }
}

// MARK: - Detail view controller delegates

extension PostsTableViewController: PostDetailViewControllerDelegate {
    func likebuttonTapped(inPost postId: Int) {
        self.tableView.reloadData()
    }
}
