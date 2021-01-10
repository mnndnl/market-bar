//
//  Double+Extensions.swift
//  marketbar
//
//  Created by Daniil Manin on 28.12.2020.
//

import Foundation

extension Double {
	
	var round2: Double {
		(self * 100.0).rounded() / 100.0
	}
	
	var priceString: String {
		round2 == 0.0 ? "-" : "\(round2)"
	}
}
