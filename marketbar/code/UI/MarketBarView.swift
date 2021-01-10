//
//  MarketBarView.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import AppKit
import Combine

final class MarketBarView: NSView {
	
	private let manager = MarketManager.shared
	
	private var menuItem: NSMenu?
	private let statusItem = NSStatusBar.system.statusItem(withLength: -1)
	private var cancellables: Set<AnyCancellable> = []
	
	func configure(menu: NSMenu?) {
		guard let _ = statusItem.button else {
			return NSApp.terminate(.none)
		}
		
		update()
		menuItem = menu
		
		manager.didUpdateSettings
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.update()
			}
			.store(in: &cancellables)
		
		manager.didUpdateTickers
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				guard let tickersCount = self?.manager.tickers.count else { return }
				guard tickersCount < 3 else { return }
				self?.update()
			}
			.store(in: &cancellables)
	}
	
	// MARK: - Private
	
	private func update() {
		prepare()
		configureStatusItem()
	}
	
	private func configureStatusItem() {
		let marketButton = MarketButton(tickers: manager.tickers, originX: 0.0)
		statusItem.button?.addSubview(marketButton)
		
		if manager.tickers.count > 2 {
			marketButton.fadeAnimation(alphaValue: 1.0)
			animationMode(marketButton: marketButton)
		} else {
			nonAnimationMode(marketButton: marketButton)
		}
	}
	
	// MARK: - Animations
	
	private func animationMode(marketButton: MarketButton) {
		statusItem.button?.frame.size.width = 160.0
		nextMarketButton(originX: marketButton.frame.width)
		
		marketButton.scrollAnimation(duration: TimeInterval(manager.tickers.count) * 4.0) { [weak self] in
			self?.nextMarketButton(originX: marketButton.frame.width)
		}
	}
	
	private func nonAnimationMode(marketButton: MarketButton) {
		statusItem.button?.frame.size.width = marketButton.frame.size.width
	}
	
	// MARK: - Market Button
	
	private func nextMarketButton(originX: CGFloat) {
		let marketButton = MarketButton(tickers: manager.tickers, originX: originX)
		statusItem.button?.addSubview(marketButton)
		
		marketButton.scrollAnimation(duration: TimeInterval(manager.tickers.count) * 8.0) { [weak self] in
			self?.nextMarketButton(originX: marketButton.frame.width)
		}
	}

	// MARK: - Other
	
	private func prepare() {
		removeMarketButtons()
	}
	
	private func removeMarketButtons() {
		statusItem.button?.subviews
			.compactMap { $0 as? MarketButton }
			.forEach { remove(button: $0) }
	}
	
	private func remove(button: MarketButton?) {
		if manager.tickers.count > 2 {
			button?.fadeAnimation(alphaValue: 0.0) {
				button?.removeFromSuperview()
			}
		} else {
			button?.removeFromSuperview()
		}
	}
}
