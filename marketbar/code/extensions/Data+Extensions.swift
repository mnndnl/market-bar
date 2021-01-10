//
//  Data+Extensions.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

extension Data {

	func decoded<T: Decodable>() -> T? {
		return try? JSONDecoder().decode(T.self, from: self)
	}
}
