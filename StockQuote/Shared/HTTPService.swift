//
//  HTTPService.swift
//  StockQuote
//
//  Created by Hyusein on 4.12.21.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSessionProtocol {}

protocol HttpServiceProtocol {
    func searchCompany(searchTerm: String, completion: @escaping ( (Result<SearchResultResponse, NetworkError>) -> Void))
    func getQuote(tickerSymbol: String, completion: @escaping ( (Result<QuoteResultResponse, NetworkError>) -> Void))
}

class HttpService: HttpServiceProtocol {
    private let searchURL = "https://stock-market-data.p.rapidapi.com/search/company-name-to-ticker-symbol"
    private let quoteURL = "https://stock-market-data.p.rapidapi.com/stock/quote"
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func searchCompany(searchTerm: String, completion: @escaping ( (Result<SearchResultResponse, NetworkError>) -> Void)) {
        guard var urlComponnents = URLComponents(string: searchURL) else { fatalError() }
        urlComponnents.queryItems = [URLQueryItem(name: "company_name", value: searchTerm)]
        guard let url = urlComponnents.url else { fatalError("Invalid URL") }
        
        let request = setUpRequest(url: url, httpMethod: "GET")
        createDataTask(request, SearchResultResponse.self, completion: { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func getQuote(tickerSymbol: String, completion: @escaping ( (Result<QuoteResultResponse, NetworkError>) -> Void)) {
        guard var urlComponnents = URLComponents(string: quoteURL) else { fatalError() }
        urlComponnents.queryItems = [URLQueryItem(name: "ticker_symbol", value: tickerSymbol)]
        guard let url = urlComponnents.url else { fatalError("Invalid URL") }
        
        let request = setUpRequest(url: url, httpMethod: "GET")
        createDataTask(request, QuoteResultResponse.self, completion: { result in
            switch result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                completion(.failure(error))
            }
        })
    }
    
    func createDataTask<T: Codable>(_ request: URLRequest,
                                    _ model: T.Type,
                                    completion: @escaping (Result<T, NetworkError>) -> Void) {
        session.dataTask(with: request) { data, response, _ in
            if !self.isResponseSuccess(response: response) {
                DispatchQueue.main.async {
                    completion(.failure(.responseError))
                }
                return
            }
            let responseData = self.decodeResponseData(data: data, type: model)
            if let responseData = responseData {
                DispatchQueue.main.async {
                    completion(.success(responseData))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    private func setUpRequest(url: URL, httpMethod: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        request.setValue("stock-market-data.p.rapidapi.com", forHTTPHeaderField: "X-RapidAPI-Host")
        request.setValue("770631574fmshf0cc02e3486f0a3p1a118ajsn322cca4f3c33", forHTTPHeaderField: "X-RapidAPI-Key")
        return request
    }
    
    private func decodeResponseData<T: Decodable>(data: Data?, type: T.Type) -> T? {
        if let data = data {
            do {
                let decoder = JSONDecoder()
                let json = try decoder.decode(type, from: data)
                return json
            } catch let error {
                print(error)
                return nil
            }
        }
        return nil
    }
    
    private func isResponseSuccess(response: URLResponse?) -> Bool {
        if let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) {
            return true
        }
        return false
    }
}

