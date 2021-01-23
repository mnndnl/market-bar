//
//  DefaultConfiguration.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

fileprivate let appleTicker = Ticker(
	symbol: "AAPL",
	name: "Apple Inc.",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "equity")

fileprivate let teslaTicker = Ticker(
	symbol: "TSLA",
	name: "Tesla, Inc.",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "equity")

fileprivate let amazonTicker = Ticker(
	symbol: "AMZN",
	name: "Amazon.com, Inc.",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "equity")

extension Settings {
	
	static let `default` = Settings(
		tickers: [appleTicker, teslaTicker, amazonTicker],
		updateInterval: 30.0,
		changesInPercentage: true,
		maxNumberOfTickers: 10)
}
