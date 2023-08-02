//
//  DetailsInteractorTest.swift
//  StockQuoteTests
//
//  Created by Hyusein on 5.12.21.
//

import XCTest
@testable import StockQuote

class MockDetailsViewController: DetailsViewControllerProtocol {
    var viewModel: Quote?
    var startSpinnerCalls = 0
    var stopSpinnerCalls = 0
    var reloadDataCalls = 0
    
    func reloadData(viewModel: Quote?) {
        reloadDataCalls += 1
        self.viewModel = viewModel
    }
    
    func startSpinner() {
        startSpinnerCalls += 1
    }
    
    func stopSpinner() {
        stopSpinnerCalls += 1
    }
    

    
    
}

class DetailsInteractorTest: XCTestCase {
    var detailsInteractor: DetailsInteractor!
    var mockViewControler: MockDetailsViewController!
    var httpService: MockHTTPService!
    let quoteResponse = QuoteResultResponse(date: "", status: "", quote: Quote(companyName: "test name", currentPrice: 0, todayHigh: 0, todayLow: 0, todayVolume: 0, todayChange: 0))
    override func setUpWithError() throws {
        mockViewControler = MockDetailsViewController()
        httpService = MockHTTPService()
    }

    override func tearDownWithError() throws {
        mockViewControler = nil
        httpService = nil
    }

    func testSearchTriggeredSuccess() {
        httpService.isGetQuoteSuccess = true
        httpService.quoteResponse = quoteResponse
        detailsInteractor = DetailsInteractor(httpService: httpService)
        detailsInteractor.symbol = "test symbol"
        detailsInteractor.viewController = mockViewControler
        detailsInteractor.getCompanyQuote()
        
   
            XCTAssertEqual(mockViewControler.startSpinnerCalls, 1)
        XCTAssertEqual(mockViewControler.stopSpinnerCalls, 1)
        XCTAssertEqual(mockViewControler.viewModel?.companyName, quoteResponse.quote.companyName)
        XCTAssertEqual(mockViewControler.viewModel?.todayLow, quoteResponse.quote.todayLow)
        XCTAssertEqual(mockViewControler.viewModel?.todayHigh, quoteResponse.quote.todayHigh)
        XCTAssertEqual(mockViewControler.viewModel?.todayVolume, quoteResponse.quote.todayVolume)

        }
    
    func testSearchTriggeredFailure() {
        httpService.isGetQuoteSuccess = false
        httpService.quoteResponse = quoteResponse
        detailsInteractor = DetailsInteractor(httpService: httpService)
        detailsInteractor.symbol = "test symbol"
        detailsInteractor.viewController = mockViewControler
        detailsInteractor.getCompanyQuote()
        
   
            XCTAssertEqual(mockViewControler.startSpinnerCalls, 1)
        XCTAssertEqual(mockViewControler.stopSpinnerCalls, 1)
        XCTAssertNil(mockViewControler.viewModel, "ViewModel is nil")
    }
}
