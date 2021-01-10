//
//  TickerView.swift
//  marketbar
//
//  Created by Daniil Manin on 03.01.2021.
//

import AppKit

final class TickerView: NSView, NibLoadable {
	
	var remove: ((Ticker) -> Void)? = .none
	
	@IBOutlet private var tickerPriceLabel: NSTextField!
	@IBOutlet private var tickerNameLabel: NSTextField!
	@IBOutlet private var removeButton: NSButton!
	
	private var ticker: Ticker?

	func update(ticker: Ticker) {
		self.ticker = ticker
		if let priceString = ticker.price?.priceString {
			tickerPriceLabel.stringValue = "\(ticker.simpleSymbol) \(priceString)"
		}
		if let name = ticker.name {
			tickerNameLabel.stringValue = "\(name)"
		}
		tickerNameLabel.isHidden = ticker.isCurrency
		removeButton.isHidden = MarketManager.shared.tickers.count == 1
	}
	
	// MARK: - Actions
	
	@IBAction private func onRemove(_ sender: NSButton) {
		guard let ticker = ticker else { return }
		remove?(ticker)
	}
}
