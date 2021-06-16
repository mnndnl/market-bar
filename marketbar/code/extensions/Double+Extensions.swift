//
//  Double+Extensions.swift
//  marketbar
//
//  Created by Daniil Manin on 28.12.2020.
//

import Foundation

extension Double {
	
	// MARK: - Private

	private func toString(decimal: Int = 9) -> String {
		let value = decimal < 0 ? 0 : decimal
		var string = String(format: "%.\(value)f", self)
		
		while string.last == "0" || string.last == "." {
			if string.last == "." {
				string = String(string.dropLast())
				break
			}
			string = String(string.dropLast())
		}
		return string
	}
}
