//
//  MarketButton.swift
//  marketbar
//
//  Created by Daniil Manin on 03.01.2021.
//

import AppKit

final class MarketButton: NSStatusBarButton {
	
	var handler: (() -> Void)? = .none
	
	var tickers: [Ticker]
	private let initOriginX: CGFloat
	
	init(tickers: [Ticker], originX: CGFloat) {
		self.tickers = tickers
		self.initOriginX = originX
		super.init(frame: .zero)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Action
	
	func set(ticker: Ticker) {
		tickers = [ticker]
		configure()
	}
	
	// MARK: - Animations
	
	func scrollAnimation(duration: TimeInterval, completion: (() -> Void)? = .none) {
		NSAnimationContext.runAnimationGroup { [weak self] context in
			context.duration = duration
			context.timingFunction = CAMediaTimingFunction(name: .linear)
			context.completionHandler = {
				if self?.superview != .none {
					completion?()
					self?.removeFromSuperview()
				}
			}
			self?.animator().frame.origin.x = -frame.width
		}
	}
	
	func fadeAnimation(alphaValue: CGFloat, duration: TimeInterval = 2.5, completion: (() -> Void)? = .none) {
		self.alphaValue = 1.0 - alphaValue
		NSAnimationContext.runAnimationGroup { [weak self] context in
			context.duration = duration
			context.timingFunction = CAMediaTimingFunction(name: .linear)
			context.completionHandler = {
				completion?()
			}
			self?.animator().alphaValue = alphaValue
		}
	}
	
	// MARK: - Private
	
	private func configure() {
		let showPremarketInBar = MarketManager.shared.showPremarketInBar
		let tickersString = tickers
			.map { " \($0.simpleSymbol) \(showPremarketInBar ? $0.priceString : $0.lastPriceString)" }
			.reduce("", +)
		
		title = tickersString
		sizeToFit()
		frame.origin.x = initOriginX
		frame.size.height = 25.0
		
		target = self
		action = #selector(onButton(sender:))
		sendAction(on: [.leftMouseUp, .rightMouseUp])
	}
	
	@objc private func onButton(sender: NSStatusBarButton) {
		guard let superview = sender.superview else { return }
		let contextMenu = ContextMenu()
		contextMenu.show(relativeTo: sender.bounds, of: superview, preferredEdge: NSRectEdge.maxY)
	}
}
