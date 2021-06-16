//
//  TickerView.swift
//  marketbar
//
//  Created by Daniil Manin on 03.01.2021.
//

import AppKit

final class TickerView: NSView, NibLoadable {
	
	var ticker: Ticker?
	
	var remove: ((Ticker) -> Void)? = .none
	var up: ((Ticker) -> Void)? = .none
	var down: ((Ticker) -> Void)? = .none
	
	@IBOutlet private var tickerNameLabel: NSTextField!
	@IBOutlet private var tickerPriceLabel: NSTextField!
	
	@IBOutlet private var toolbar: NSStackView!
	@IBOutlet private var removeButton: NSButton!
	@IBOutlet private var upButton: NSButton!
	@IBOutlet private var downButton: NSButton!
	@IBOutlet private var toolbarTrailingCostraint: NSLayoutConstraint!
	
	private var enabledEditMode: Bool = false
	private var showTickerName: Bool = true
	
	func set(showTickerName: Bool) {
		self.showTickerName = showTickerName
		tickerNameLabel.isHidden = !showTickerName
	}
	
	func editMode(enabled: Bool) {
		enabledEditMode = enabled
		toolbar.isHidden = !enabled
		toolbarTrailingCostraint.constant = enabled ? 0.0 : -64.0
		updateOrderButton()
	}

	func update(ticker: Ticker) {
		self.ticker = ticker
		let priceString = ticker.priceString
		tickerPriceLabel.stringValue = "\(ticker.simpleSymbol) \(priceString) \(ticker.prePostPrice)"
		
		if let name = ticker.name {
			tickerNameLabel.stringValue = "\(name)"
		}
		tickerNameLabel.isHidden = ticker.isCurrency
		updateOrderButton()
	}
	
	// MARK: - Actions
	
	@IBAction private func onRemove(_ sender: NSButton) {
		guard let ticker = ticker else { return }
		remove?(ticker)
		sender.state = .off
	}
	
	@IBAction private func onUp(_ sender: NSButton) {
		guard let ticker = ticker else { return }
		up?(ticker)
		updateOrderButton()
		sender.state = .off
	}
	
	@IBAction private func onDown(_ sender: NSButton) {
		guard let ticker = ticker else { return }
		down?(ticker)
		updateOrderButton()
		sender.state = .off
	}
	
	@IBAction private func onTicker(_ sender: NSButton) {
		guard let link = ticker?.link else { return }
		NSWorkspace.shared.open(link)
	}
	
	// MARK: - Private
	
	private func updateOrderButton() {
		let manager = MarketManager.shared
		let orderIndices = manager.tickers.map { $0.orderIndex }
		let minIndex = orderIndices.min() ?? 0
		let maxIndex = orderIndices.max() ?? 0
		upButton.isHidden = ticker?.orderIndex == minIndex
		downButton.isHidden = ticker?.orderIndex == maxIndex
	}
}
