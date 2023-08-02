//
//  DetailsViewController.swift
//  StockQuote
//
//  Created by Hyusein on 4.12.21.
//

import UIKit

protocol DetailsViewControllerProtocol: AnyObject {
    func reloadData(viewModel: Quote?)
    func startSpinner()
    func stopSpinner()
}

class DetailsViewController: UITableViewController, DetailsViewControllerProtocol {
    private let cellReuseIdentifier = "cell"
    var interactor: DetailsInteractorProtocol?
    var viewModel: Quote?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
        interactor?.getCompanyQuote()
    }
    
    
    func reloadData(viewModel: Quote?) {
        self.viewModel = viewModel
        tableView.reloadData()
    }
    
    func startSpinner() {
        present(createLoadingIndicator(), animated: true, completion: nil)
    }
    
    func stopSpinner() {
        dismiss(animated: false, completion: nil)
    }
    
    private func setUpTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.bounces = false
    }
    
    private func createLoadingIndicator() -> UIAlertController {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        alert.view.addSubview(loadingIndicator)
        return alert
    }
}

extension DetailsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        let section = indexPath.section
        let cell = setUpCell()
        var text = ""
        switch section {
        case 0:
            text = viewModel.companyName
        case 1:
            let val = viewModel.currentPrice
            text = String(describing: val)
        case 2:
            let val = viewModel.todayHigh
            text = String(format: "%.4f", val)
        case 3:
            let val = viewModel.todayLow
            text = String(format: "%.4f", val)
        case 4:
            let val = viewModel.todayVolume
            text = String(describing: val)
        case 5:
            let val = viewModel.todayChange
            text = String(format: "%.4f", val)
        default:
            text = ""
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func setUpCell() -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: cellReuseIdentifier)
        else {
            fatalError()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Company Name: "
        case 1:
            return "Current Price: "
        case 2:
            return "Today's High: "
        case 3:
            return "Today's Low: "
        case 4:
            return "Today's Volume: "
        case 5:
            return "Today's Change: "
        default:
            return ""
        }
    }
    
}
