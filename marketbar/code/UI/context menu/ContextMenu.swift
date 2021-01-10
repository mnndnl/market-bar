//
//  ContextMenu.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import AppKit

final class ContextMenu: NSPopover {
	
	override init() {
		super.init()
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Private
	
	private func configure() {
		let storyboard = NSStoryboard(name: "Main", bundle: .none)
		guard let tickersViewController = storyboard.instantiateController(withIdentifier: "TickersViewController") as? TickersViewController else { return }
		tickersViewController.close = { [weak self] in
			self?.close()
		}
		contentViewController = tickersViewController
		animates = true
		behavior = .transient
	}
}
