//
//  Ticker.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

struct Ticker: Equatable, Codable {
	
	var symbol: String
	var name: String?
	var price: Double?
	var previousClose: Double?
	var quoteType: String = ""
}

// MARK: -

extension Ticker {
	
	var isCurrency: Bool { quote == .currency }
	var quote: Quote { Quote.from(rawValue: quoteType) }
	var link: URL? { URL(string: "https://finance.yahoo.com/quote/\(symbol)") }
	
	var absoluteChange: Double {
		guard let price = price, let previousClose = previousClose else { return 0.0 }
		return price - previousClose
	}
	
	var relativeChange: Double {
		guard let price = price, let previousClose = previousClose, previousClose != 0.0 else { return 0.0 }
		return (price - previousClose) / previousClose
	}
	
	var simpleSymbol: String {
		guard !isCurrency else { return name ?? "currency" }
		var symbol = self.symbol
		if let dotRange = symbol.range(of: ".") {
			symbol.removeSubrange(dotRange.lowerBound..<symbol.endIndex)
		}
		return symbol
	}
}

// MARK: - Coding Keys

extension Ticker {
	
	enum CodingKeys: String, CodingKey {
		case symbol
		case quoteType
		case name = "shortName"
		case price = "regularMarketPrice"
		case previousClose = "regularMarketPreviousClose"
	}
}
