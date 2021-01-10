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
	
	private let manager = MarketManager.shared
	private var cancellables: Set<AnyCancellable> = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		configure()
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		resetResponder()
	}

	// MARK: - Actions
	
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
		tickerStackView.arrangedSubviews.forEach { subview in
			guard subview is TickerView else { return }
			subview.removeFromSuperview()
		}
		manager.tickers.reversed().forEach { ticker in
			let tickerView = TickerView.createFromNib()
			tickerView.update(ticker: ticker)
			tickerView.remove = { [weak self] ticker in
				self?.remove(ticker: ticker)
			}
			tickerStackView.insertArrangedSubview(tickerView, at: 0)
		}
		tickerTextField.isHidden = manager.isFulledStorage
	}
	
	private func add(ticker: String) {
		manager.add(tickerString: ticker)
		resetResponder()
	}
	
	private func remove(ticker: Ticker) {
		manager.remove(ticker: ticker)
	}
	
	private func resetResponder() {
		tickerStackView.window?.makeFirstResponder(tickerStackView.window)
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
