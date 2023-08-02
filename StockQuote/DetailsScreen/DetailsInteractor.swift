//
//  DetailsInteractor.swift
//  StockQuote
//
//  Created by Hyusein on 4.12.21.
//

protocol DetailsInteractorProtocol {
    func getCompanyQuote()
}

class DetailsInteractor: DetailsInteractorProtocol {
    private let httpService: HttpServiceProtocol
    weak var viewController: DetailsViewControllerProtocol?
    var symbol: String?
    
    init(httpService: HttpServiceProtocol = HttpService()) {
        self.httpService = httpService
    }
    
    func getCompanyQuote() {
        guard let symbol = symbol else { return }
        viewController?.startSpinner()
        httpService.getQuote(tickerSymbol: symbol, completion: { [weak self] result in
            guard let self = self else { return }
            self.viewController?.stopSpinner()
            switch result {
            case .success(let response):
                self.viewController?.reloadData(viewModel: response.quote)
            case .failure(let error):
                print(error)
                self.viewController?.reloadData(viewModel: nil)
            }
            
        })
    }
}
