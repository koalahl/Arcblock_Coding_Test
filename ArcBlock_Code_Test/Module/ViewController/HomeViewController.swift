//
//  ViewController.swift
//  ArcBlock_Code_Test
//
//  Created by HanLiu on 2021/2/27.
//

import UIKit
import SafariServices

// MARK: - LifeCycle

/// Search users through search bar text.
/// the tableVIewCell's height is autoDimension.
class HomeViewController: UIViewController {

    private lazy var newsListTableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(NewsCell.self, forCellReuseIdentifier: NewsCell.reuseIdentifier)
        table.dataSource = self
        table.delegate = self
        table.estimatedRowHeight = UITableView.automaticDimension
        table.tableFooterView = UIView()
        return table
    }()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var newsList: [News] = [News]()
    private var isLoadingMore = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        updateLayout()
        requestGitUserList(type: .refresh)
    }
    
    func setupViews() {
        view.addSubview(newsListTableView)
        view.addSubview(loadingView)
        loadingView.isHidden = true
        // Add Pull to Refresh
        newsListTableView.refreshControl = UIRefreshControl()
        newsListTableView.refreshControl?.addTarget(self, action:#selector(handleRefreshControl), for: .valueChanged)
    }
    
    func updateLayout() {
        let viewLayoutGuide = self.view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            newsListTableView.topAnchor.constraint(equalTo: viewLayoutGuide.topAnchor, constant: .zero),
            newsListTableView.leftAnchor.constraint(equalTo: viewLayoutGuide.leftAnchor, constant: .zero),
            newsListTableView.rightAnchor.constraint(equalTo: viewLayoutGuide.rightAnchor, constant: .zero),
            newsListTableView.bottomAnchor.constraint(equalTo: viewLayoutGuide.bottomAnchor, constant: .zero),

            loadingView.centerXAnchor.constraint(equalTo: viewLayoutGuide.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: viewLayoutGuide.centerYAnchor),
        ])
    }
    
    @objc func handleRefreshControl() {
        loadData(type: .refresh)
    }
}

// MARK: - Data Request
extension HomeViewController {
    
    /// Request data .
    /// when pull to refresh, then type is refresh.
    /// when scroll up on bottom , the type is loadMore.
    /// - Parameter type: refresh/loadMore
    func loadData(type: RequestType) {
        RequestManager.shared.getArcBlockNews(loadType: type, completion: { [weak self] users in
            guard let self = self else { return }
            self.isLoadingMore = false
            // Hidden loadingView
            self.loadingView.stopAnimating()
            self.loadingView.isHidden = true
            // Dismiss the refresh control.
            self.newsListTableView.refreshControl?.endRefreshing()

            if let users = users {
                //Reload user list
                switch type {
                case .refresh:
                    self.newsList = users
                case .loadMore:
                    self.newsList.append(contentsOf: users)
                }
                self.newsListTableView.reloadData()
            }
        })
    }
    
    func requestGitUserList(type: RequestType) {
        loadingView.isHidden = false
        loadingView.startAnimating()
        loadData(type: type)
    }
}

// MARK: - Delegate
// MARK: UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.reuseIdentifier) as! NewsCell
        let news = newsList[indexPath.row]
        cell.applyData(news)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = newsList[indexPath.row]
        guard let link = news.link, let webUrl = URL(string: link) else { return }
        let webVC = SFSafariViewController(url: webUrl)
        webVC.modalPresentationStyle = .fullScreen
        self.present(webVC, animated: true, completion: nil)
    }

}
