//
//  TickersViewController.swift
//  marketbar
//
//  Created by Daniil Manin on 03.01.2021.
//

import AppKit
import Combine

final class TickersViewController: NSViewController {
	
	var close: (() -> Void)? = .none
		
	@IBOutlet private var tickerStackView: NSStackView!
	@IBOutlet private var tickerTextField: NSTextField!
	@IBOutlet private var editButton: NSButton!
	@IBOutlet private var marketButton: NSButton!
	@IBOutlet private var changeButton: NSButton!
	@IBOutlet private var scrollAnimationButton: NSButton!
	@IBOutlet private var showNameButton: NSButton!
	
	private let manager = MarketManager.shared
	private var cancellables: Set<AnyCancellable> = []
	
	private var enabledEditMode: Bool = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		resetResponder()
		NSRunningApplication.current.activate(options: [.activateIgnoringOtherApps, .activateAllWindows])
	}

	// MARK: - Actions
	
	@IBAction private func onShowName(_ sender: NSButton) {
		guard !enabledEditMode else { return }
		manager.showTickerName = !manager.showTickerName
	}
	
	@IBAction private func onScrollAnimation(_ sender: NSButton) {
		guard !enabledEditMode else { return }
		manager.showOnlyOneTicker = !manager.showOnlyOneTicker
	}
	
	@IBAction private func onEdit(_ sender: NSButton) {
		editMode()
	}
	
	@IBAction private func onMarket(_ sender: NSButton) {
		guard !enabledEditMode else { return }
		manager.showPremarketInBar = !manager.showPremarketInBar
	}
	
	@IBAction private func onChange(_ sender: NSButton) {
		
	}
	
	@IBAction private func onClose(_ sender: NSButton) {
		close?()
	}
	
	@IBAction private func onQuit(_ sender: NSButton) {
		NSApp.terminate(.none)
	}
	
	// MARK: - Private
	
	private func configure() {
		update()
		tickerTextField.delegate = self
		showNameButton.state = manager.showTickerName ? .on : .off
		scrollAnimationButton.state = manager.showOnlyOneTicker ? .off : .on
		marketButton.state = manager.showPremarketInBar ? .off : .on
		
		manager.didUpdateSettings
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.update()
			}
			.store(in: &cancellables)
		
		manager.didUpdateTickers
			.receive(on: RunLoop.main)
			.sink { [weak self] _ in
				self?.update()
			}
			.store(in: &cancellables)
	}
	
	private func update() {
		guard !enabledEditMode else { return }
		tickerStackView.arrangedSubviews.forEach { subview in
			guard subview is TickerView else { return }
			subview.removeFromSuperview()
		}
		manager.tickers.reversed().forEach { ticker in
			let tickerView = TickerView.createFromNib()
			tickerView.update(ticker: ticker)
			tickerView.remove = { [weak self] ticker in
				self?.remove(tickerView: tickerView)
				self?.manager.remove(ticker: ticker)
			}
			tickerView.up = { [weak self] ticker in
				self?.up(tickerView: tickerView)
				self?.manager.upOrder(ticker: ticker)
			}
			tickerView.down = { [weak self] ticker in
				self?.down(tickerView: tickerView)
				self?.manager.downOrder(ticker: ticker)
			}
			tickerView.set(showTickerName: manager.showTickerName)
			tickerStackView.insertArrangedSubview(tickerView, at: 0)
		}
		tickerTextField.isHidden = manager.isFulledStorage
	}
	
	private func add(ticker: String) {
		manager.add(tickerString: ticker)
		resetResponder()
	}
	
	private func resetResponder() {
		tickerStackView.window?.makeFirstResponder(tickerStackView.window)
	}
	
	private func editMode() {
		enabledEditMode = !enabledEditMode
		tickerStackView.arrangedSubviews
			.compactMap { $0 as? TickerView }
			.forEach { tickerView in
				tickerView.editMode(enabled: enabledEditMode)
			}
		
		marketButton.isHidden = enabledEditMode
		changeButton.isHidden = enabledEditMode
		scrollAnimationButton.isHidden = enabledEditMode
		showNameButton.isHidden = enabledEditMode
	}
	
	private func remove(tickerView: TickerView) {
		tickerView.removeFromSuperview()
	}
	
	private func up(tickerView: TickerView) {
		let superView = tickerView.superview as? NSStackView
		let orderIndex = tickerView.ticker?.orderIndex ?? 0
		let newOrderIndex = orderIndex - 1
		(superView?.arrangedSubviews[newOrderIndex] as? TickerView)?.ticker?.orderIndex = orderIndex
		tickerView.ticker?.orderIndex = newOrderIndex
		superView?.insertArrangedSubview(tickerView, at: newOrderIndex)
	}
	
	private func down(tickerView: TickerView) {
		let superView = tickerView.superview as? NSStackView
		let orderIndex = tickerView.ticker?.orderIndex ?? 0
		let newOrderIndex = orderIndex + 1
		(superView?.arrangedSubviews[newOrderIndex] as? TickerView)?.ticker?.orderIndex = orderIndex
		tickerView.ticker?.orderIndex = newOrderIndex
		superView?.insertArrangedSubview(tickerView, at: newOrderIndex)
	}
}

extension TickersViewController: NSTextFieldDelegate {
	
	func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		guard (commandSelector == #selector(NSResponder.insertNewline(_:))) else { return false }
		add(ticker: textView.string)
		tickerTextField.stringValue = ""
		return true
	}
}
