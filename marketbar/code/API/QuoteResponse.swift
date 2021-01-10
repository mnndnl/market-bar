//
//  QuoteResponse.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

struct QuoteResponse: Codable {
	let quoteResponse: ResultResponse
}

struct ResultResponse: Codable {
	let result: [Ticker]
}
