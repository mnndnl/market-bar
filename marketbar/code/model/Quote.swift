//
//  Quote.swift
//  marketbar
//
//  Created by Daniil Manin on 08.01.2021.
//

import Foundation

enum Quote: String {
	
	case etf = "etf"
	case equity = "equity"
	case currency = "currency"
	case crypto = "CRYPTOCURRENCY"
	case unknown = "unknown"
}

extension Quote {
	
	static func from(rawValue: String) -> Quote {
		Quote(rawValue: rawValue.lowercased()) ?? .unknown
	}
}
