//
//  AppDelegate.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet private weak var appMenu: NSMenu?
	private var marketBarView = MarketBarView()
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		marketBarView.configure(menu: appMenu)
	}
}
