//
//  ViewController.swift
//  News
//
//  Created by Nguyễn Văn Hiếu on 12/12/24.
//

import UIKit
import SafariServices

class ViewController: UIViewController {
    
    // MARK: - Variables
    private var viewModels = [NewsTableViewCellViewModel]()
    private var articles = [Article]()
    
    // MARK: - UI Componnets In View
    private let newsTableView: UITableView = {
        let _tableView = UITableView()
        _tableView.register(NewsTableViewCell.self,
                            forCellReuseIdentifier: NewsTableViewCell.identifier)
        _tableView.rowHeight = UITableView.automaticDimension
        _tableView.estimatedRowHeight = 150
        return _tableView
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "News"
        view.backgroundColor = .systemBackground
        
        ///Setup Table View
        view.addSubview(newsTableView)
        newsTableView.dataSource = self
        newsTableView.delegate = self
        
        ///Setup Search Bar
        setupSearchController()
        
        fetchTopStories()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newsTableView.frame = view.bounds
    }
    
    private func setupSearchController() {
        self.searchController.searchResultsUpdater = self
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search..."
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
}

extension ViewController {
    
    // MARK: - Fetch Top Stories
    private func fetchTopStories() {
        APICaller.shared.getTopStories { [weak self] result in
            switch result {
            case .success(let articles):
                // Check nếu có url cho phép navigation to SFSafari
                self?.articles = articles
                self?.viewModels = articles.compactMap({
                    NewsTableViewCellViewModel(title: $0.title,
                                               subtitle: $0.description ?? "No Description",
                                               imageURL: URL(string: $0.urlToImage ?? "")
                    )
                })
                
                // Refresh UI
                DispatchQueue.main.async {
                    self?.newsTableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
}


extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("DEBUG:", searchController.searchBar.text)
    }
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsTableViewCell.identifier,
                                                       for: indexPath) as? NewsTableViewCell else {
            fatalError()
        }
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = articles[indexPath.row]
        
        guard let url = URL(string: article.url ?? "") else {
            return
        }
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

