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
	quoteType: "equity",
	orderIndex: 0)

fileprivate let teslaTicker = Ticker(
	symbol: "TSLA",
	name: "Tesla, Inc.",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "equity",
	orderIndex: 1)

fileprivate let gmeTicker = Ticker(
	symbol: "GME",
	name: "GameStop Corporation",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "equity",
	orderIndex: 2)

fileprivate let dogeTicker = Ticker(
	symbol: "DOGE-USD",
	name: "Dogecoin USD",
	price: 0.0,
	previousClose: 0.0,
	quoteType: "cryptocurrency",
	orderIndex: 3)

extension Settings {
	
	static let `default` = Settings(
		tickers: [appleTicker, teslaTicker, gmeTicker, dogeTicker],
		updateInterval: 30.0,
		changesInPercentage: true)
}
