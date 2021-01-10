//
//  NibLoadable.swift
//  marketbar
//
//  Created by Daniil Manin on 07.01.2021.
//

import AppKit

protocol NibLoadable {
	
	static var nibName: String { get }
	static func createFromNib(in bundle: Bundle) -> Self
}

extension NibLoadable where Self: NSView {

	static var nibName: String {
		return String(describing: Self.self)
	}

	static func createFromNib(in bundle: Bundle = Bundle.main) -> Self {
		var topLevelArray: NSArray? = nil
		bundle.loadNibNamed(NSNib.Name(nibName), owner: self, topLevelObjects: &topLevelArray)
		let views = Array<Any>(topLevelArray!).filter { $0 is Self }
		return views.last as! Self
	}
}
