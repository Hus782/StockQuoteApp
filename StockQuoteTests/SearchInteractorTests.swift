//
//  SearchInteractorTests.swift
//  StockQuoteTests
//
//  Created by Hyusein on 5.12.21.
//

import XCTest
@testable import StockQuote

class MockSearchViewController: SearchViewControllerProtocol {
    var loadDataCalls = 0
    var companies: [CompanyViewModel] = []
    
    func loadData(companies: [CompanyViewModel]) {
        loadDataCalls += 1
        self.companies = companies
    }

}

class SearchInteractorTests: XCTestCase {
    var seachInteractor: SearchInteractor!
    var mockViewControoler: MockSearchViewController!
    var httpService: MockHTTPService!
    
    override func setUpWithError() throws {
        mockViewControoler = MockSearchViewController()
        httpService = MockHTTPService()
    }

    override func tearDownWithError() throws {
        mockViewControoler = nil
        httpService = nil
    }

    // cannot write more tests because api is not working, response is always the same
    func testSearchTriggered() {
        httpService.isSearchSuccess = true
        seachInteractor = SearchInteractor(httpService: httpService)
        seachInteractor.viewController = mockViewControoler
        seachInteractor.searchTriggered(with: "test")
        
   
            XCTAssertEqual(mockViewControoler.loadDataCalls, 1)
        XCTAssertEqual(mockViewControoler.companies.count, 1)

        }
}
