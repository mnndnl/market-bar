//
//  Encodable+Extensions.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

extension Encodable {

	func encoded() -> Data? {
		return try? JSONEncoder().encode(self)
	}
}
