//
//  SearchViewController.swift
//  StockQuote
//
//  Created by Hyusein on 4.12.21.
//

import UIKit

protocol SearchViewControllerProtocol: AnyObject {
    func loadData(companies: [CompanyViewModel])
}

class SearchViewController: UITableViewController, SearchViewControllerProtocol {
    var interactor: SearchInteractorProtocol?
    private var searchTerm = ""
    private let cellReuseIdentifier = "cell"
    private var companies: [CompanyViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSeachBar()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
    }
    
    func loadData(companies: [CompanyViewModel]) {
        self.companies = companies
        tableView.reloadData()
    }
    
    private func setUpSeachBar() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search company by name"
        navigationItem.searchController = search
    }
    
    private func navigateToDetails(symbol: String) {
        let detailsViewController = DetailsViewController()
        let detailsInteractor = DetailsInteractor()
        detailsInteractor.viewController = detailsViewController
        detailsViewController.interactor = detailsInteractor
        detailsInteractor.symbol = symbol
        self.navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension SearchViewController: UISearchResultsUpdating  {
    func updateSearchResults(for searchController: UISearchController) {
        if let text = searchController.searchBar.text {
            interactor?.searchTriggered(with: text)
        }
    }
}

extension SearchViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let company = companies[safe: indexPath.row] {
            navigateToDetails(symbol: company.name)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier)
        else {
            fatalError()
        }
        if let company = companies[safe: indexPath.row] {
            cell.textLabel?.text = company.name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companies.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// An extension for safely getting elements from array
extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
