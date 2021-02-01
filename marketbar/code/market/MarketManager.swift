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
	
	func updateSettings() {
		updateTickers { [weak self] tickers in
			self?.settings.tickers = tickers
			if let settings = self?.settings {
				self?.storage.settings = settings
				self?.didUpdateSettings.send(settings)
			}
		}
	}
	
	// MARK: - Tickers
	
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
