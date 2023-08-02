//
//  HTTPServiceTests.swift
//  StockQuoteTests
//
//  Created by Hyusein on 5.12.21.
//

import XCTest
@testable import StockQuote

class MockURLSession: URLSessionProtocol {
    var result: (Data?, URLResponse?, Error?)! = nil
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        completionHandler(result.0, result.1, result.2)
        return MockURLSessionDataTask(resume: {})
    }
}

class MockURLSessionDataTask: URLSessionDataTask {
    init(resume: () -> Void) {}
    
    override func resume() {
        // Do nothing
    }
}

class MockHTTPService: HttpServiceProtocol {
    var isSearchSuccess = true
    var isGetQuoteSuccess = true
    var searchResponse: SearchResultResponse!
    var quoteResponse: QuoteResultResponse!
    
    func searchCompany(searchTerm: String, completion: @escaping ((Result<SearchResultResponse, NetworkError>) -> Void)) {
        isSearchSuccess ? completion(.success(searchResponse)) : completion(.failure(.responseError))
    }
    
    func getQuote(tickerSymbol: String, completion: @escaping ((Result<QuoteResultResponse, NetworkError>) -> Void)) {
        isGetQuoteSuccess ? completion(.success(quoteResponse)) : completion(.failure(.responseError))
    }
    
}

class HTTPServiceTests: XCTestCase {
    
    var mockSession: MockURLSession!
    var httpService: HttpService!
    let timoutTime = 0.3
    let dummyRequest = URLRequest(url: URL(string: "www.google.com")!)
    let successResponse = HTTPURLResponse(url: URL(string: "www.google.com")!,
                                          statusCode: 200,
                                          httpVersion: nil,
                                          headerFields: nil)!
    let badResponse = HTTPURLResponse(url: URL(string: "www.google.com")!,
                                      statusCode: 404,
                                      httpVersion: nil,
                                      headerFields: nil)!
    let searchResponse = SearchResultResponse(date: "", status: "", ticker_symbol: "Test")
    let quoteResponse = QuoteResultResponse(date: "", status: "", quote: Quote(companyName: "Test name", currentPrice: 0, todayHigh: 0, todayLow: 0, todayVolume: 0, todayChange: 0))
    
    override func setUpWithError() throws {
        mockSession = MockURLSession()
    }
    
    override func tearDownWithError() throws {
        mockSession = nil
    }
    
    func testSearchSuccess() throws {
        let data = try JSONEncoder().encode(searchResponse)
        
        mockSession.result = (data, successResponse, nil)
        httpService = HttpService(session: mockSession)
        let exp = expectation(description: "searchCompletion")
        httpService.searchCompany(searchTerm: "test", completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result.date, self.searchResponse.date)
                XCTAssertEqual(result.status, self.searchResponse.status)
                XCTAssertEqual(result.ticker_symbol, self.searchResponse.ticker_symbol)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: timoutTime)
    }
    
    func testSearchFailure() throws {
        let data = try JSONEncoder().encode(searchResponse)
        mockSession.result = (data, badResponse, nil)
        httpService = HttpService(session: mockSession)
        let exp = expectation(description: "searchCompletion completion")
        httpService.searchCompany(searchTerm: "test", completion: {
            result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: timoutTime)
    }
    
    func testGetQuoteSuccess() throws {
        let data = try JSONEncoder().encode(quoteResponse)
        
        mockSession.result = (data, successResponse, nil)
        httpService = HttpService(session: mockSession)
        let exp = expectation(description: "quoteCompletion")
        httpService.getQuote(tickerSymbol: "test", completion: {
            result in
            exp.fulfill()
            switch result {
            case .success(let result):
                XCTAssertEqual(result.date, self.quoteResponse.date)
                XCTAssertEqual(result.status, self.quoteResponse.status)
                XCTAssertEqual(result.quote.companyName, self.quoteResponse.quote.companyName)
            case .failure:
                XCTFail()
            }
        })
        wait(for: [exp], timeout: timoutTime)
    }
    
    func testGetQuoteFailure() throws {
        let data = try JSONEncoder().encode(quoteResponse)
        
        mockSession.result = (data, badResponse, nil)
        httpService = HttpService(session: mockSession)
        let exp = expectation(description: "quoteCompletion")
        httpService.getQuote(tickerSymbol: "test", completion: {
            result in
            exp.fulfill()
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual(error, .responseError)
            }
        })
        wait(for: [exp], timeout: timoutTime)
    }
    
}
