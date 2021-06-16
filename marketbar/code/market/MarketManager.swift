//
//  MarketManager.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Combine
import Foundation

final class MarketManager {
	
	static let shared = MarketManager()
	
	var didUpdateTickers = PassthroughSubject<[Ticker], Never>()
	var didUpdateSettings = PassthroughSubject<Settings, Never>()
	
	var tickers: [Ticker] { settings.tickers }
	var isFulledStorage: Bool { settings.tickers.count >= Settings.maxNumberOfTickers }
	var showOnlyOneTicker: Bool {
		get { settings.showOnlyOneTicker }
		set {
			settings.showOnlyOneTicker = newValue
			saveSettings()
		}
	}
	
	var showTickerName: Bool {
		get { settings.showTickerName }
		set {
			settings.showTickerName = newValue
			saveSettings()
		}
	}
	
	var showPremarketInBar: Bool {
		get { settings.showPremarketInBar }
		set {
			settings.showPremarketInBar = newValue
			saveSettings()
		}
	}
	
	private let service = APIService()
	private let storage = MarketStorage()
	
	private var settings: Settings
	private var timer: Timer?

	private init() {
		settings = storage.settings
		configureTimer()
		updateSettings()
	}
	
	func add(tickerString: String) {
		let ticker = Ticker(symbol: tickerString)
		storage.settings.tickers.append(ticker)
		updateSettings()
	}
	
	func remove(ticker: Ticker) {
		storage.settings.tickers.removeAll(where: { $0 == ticker })
		updateSettings()
	}
	
	func upOrder(ticker: Ticker) {
		let currentOrderIndex = ticker.orderIndex
		let previousOrderIndex = max(0, currentOrderIndex - 1)
		storage.settings.tickers[currentOrderIndex].orderIndex -= 1
		storage.settings.tickers[previousOrderIndex].orderIndex += 1
		let tempTicker = storage.settings.tickers[currentOrderIndex]
		storage.settings.tickers[currentOrderIndex] = storage.settings.tickers[previousOrderIndex]
		storage.settings.tickers[previousOrderIndex] = tempTicker
		updateSettings()
	}
	
	func downOrder(ticker: Ticker) {
		let currentOrderIndex = ticker.orderIndex
		let nextOrderIndex = min(tickers.count - 1, currentOrderIndex + 1)
		storage.settings.tickers[currentOrderIndex].orderIndex += 1
		storage.settings.tickers[nextOrderIndex].orderIndex -= 1
		let tempTicker = storage.settings.tickers[currentOrderIndex]
		storage.settings.tickers[currentOrderIndex] = storage.settings.tickers[nextOrderIndex]
		storage.settings.tickers[nextOrderIndex] = tempTicker
		updateSettings()
	}
	
	func updateSettings() {
		updateTickers { [weak self] tickers in
			self?.settings.tickers = tickers
			self?.saveSettings()
		}
	}
	
	// MARK: - Tickers
	
	private func saveSettings() {
		storage.settings = settings
		didUpdateSettings.send(settings)
	}
	
	private func updateTickers(completion: (([Ticker]) -> Void)? = .none) {
		service.update(tickers: storage.settings.tickers) { response in
			switch response {
			case .success(let tickers):
				completion?(tickers)
			case .failure(let error):
				print(error.localizedDescription)
			}
		}
	}
	
	// MARK: - Timer
	
	private func configureTimer() {
		timer?.invalidate()
		timer = Timer.scheduledTimer(timeInterval: settings.updateInterval, target: self, selector: #selector(fireTimer), userInfo: .none, repeats: true)
	}
	
	@objc private func fireTimer() {
		updateTickers { [weak self] tickers in
			self?.settings.tickers = tickers
			if let settings = self?.settings {
				self?.storage.settings = settings
				self?.didUpdateTickers.send(tickers)
			}
		}
	}
}
