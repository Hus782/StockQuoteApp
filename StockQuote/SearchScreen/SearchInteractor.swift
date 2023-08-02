//
//  SearchInteractor.swift
//  StockQuote
//
//  Created by Hyusein on 4.12.21.
//

import Foundation

struct CompanyViewModel {
    let name: String
}

protocol SearchInteractorProtocol: AnyObject {
    func searchTriggered(with searchTerm: String)
}

class SearchInteractor: SearchInteractorProtocol {
    private let httpService: HttpServiceProtocol
    private let company = CompanyViewModel(name: "AAPL") // dummy company 
    weak var viewController: SearchViewControllerProtocol?
    
    init(httpService: HttpServiceProtocol = HttpService()) {
        self.httpService = httpService
    }
    
    func searchTriggered(with searchTerm: String) {
        //       Hardcoded search result
        viewController?.loadData(companies: [company])
        
        //         coded out for now because api is not working properly
        //        httpService.searchCompany(searchTerm: searchTerm, completion: { [weak self] result in
        //            guard let self = self else { return }
        //            switch result {
        //            case .success(let response):
        //                let company = self.responseToViewModel(response: response)
        //                self.viewController?.loadData(companies: [company])
        //            case .failure(let error):
        //                print(error)
        //                self.viewController?.loadData(companies: [])
        //        }
        //
        //    })
        
    }
    
    private func responseToViewModel(response: SearchResultResponse) -> CompanyViewModel {
        return CompanyViewModel(name: response.ticker_symbol)
    }
}
