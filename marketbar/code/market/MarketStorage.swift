//
//  MarketStorage.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

final class MarketStorage {
	
	var settings: Settings {
		get { getSettings() }
		set { set(settings: newValue) }
	}
	
	private let userDefaults = UserDefaults.standard
	private let settingsKey: String = "com.manin.marketbar.settings"
	
	// MARK: - Private
	
	private func getSettings() -> Settings {
		let data = userDefaults.value(forKey: settingsKey) as? Data
		let settings = data?.decoded() ?? Settings.default
		return checkOrderIndices(for: settings)
	}
	
	private func set(settings: Settings?) {
		guard let data = settings?.encoded() else { return }
		userDefaults.set(data, forKey: settingsKey)
	}
	
	// NOTE: - For test clean
	
	private func removeSettings() {
		userDefaults.removeObject(forKey: settingsKey)
	}
	
	// NOTE: - Adding order indices
	
	private func checkOrderIndices(for settings: Settings) -> Settings {
		guard settings.tickers.contains(where: { $0.orderIndex == -1 }) else { return settings }
		var newSettings = settings
		let newTickers = settings.tickers.enumerated().compactMap { index, ticker in
			Ticker(symbol: ticker.symbol, name: ticker.name, price: ticker.price, previousClose: ticker.previousClose, quoteType: ticker.quoteType, marketState: ticker.marketState, preMarketPrice: ticker.preMarketPrice, postMarketPrice: ticker.postMarketPrice, orderIndex: index)
		}
		newSettings.tickers = newTickers
		set(settings: newSettings)
		return newSettings
	}
}
