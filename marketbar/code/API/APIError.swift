//
//  APIError.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Foundation

enum APIError: Error {
	
	case unknown
	case decodingError
	case invalidURL
	case emptyRequest
	case httpError(Int)
}
