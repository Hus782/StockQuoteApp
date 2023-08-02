//
//  Codables.swift
//  StockQuote
//
//  Created by Hyusein on 5.12.21.
//

import Foundation

struct SearchResultResponse: Codable {
    let date: String
    let status: String
    let ticker_symbol: String
}

struct QuoteResultResponse: Codable {
    let date: String
    let status: String
    let quote: Quote
}

struct Quote : Codable {
    
    let companyName: String
    let currentPrice: Float
    let todayHigh: Float
    let todayLow: Float
    let todayVolume: Int
    let todayChange: Float
    
    private enum CodingKeys : String, CodingKey {
        case companyName = "Company Name"
        case currentPrice = "Current Price"
        case todayHigh = "Today's High"
        case todayLow = "Today's Low"
        case todayVolume = "Today's Volume"
        case todayChange = "Today's Change"
    }
}
