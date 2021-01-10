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
		return data?.decoded() ?? Settings.default
	}
	
	private func set(settings: Settings?) {
		guard let data = settings?.encoded() else { return }
		userDefaults.set(data, forKey: settingsKey)
	}
	
	// NOTE: - For test clean
	
	private func removeSettings() {
		userDefaults.removeObject(forKey: settingsKey)
	}
}
