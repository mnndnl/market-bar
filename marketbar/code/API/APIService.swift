//
//  APIService.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Combine
import Foundation

typealias TickersResponse = Result<[Ticker], Error>

final class APIService {
	
	private var cancellable: AnyCancellable?
	private let endpoint: String = "https://query1.finance.yahoo.com/v7/finance/quote?symbols="
	
	func add(tickerString: String, result: @escaping (TickersResponse) -> Void) {
		let ticker = Ticker(symbol: tickerString, name: "", price: 0.0, previousClose: 0.0)
		update(tickers: [ticker], result: result)
	}
	
	func update(tickers: [Ticker], result: @escaping (TickersResponse) -> Void) {
		guard !tickers.isEmpty else {
			result(.failure(APIError.emptyRequest))
			return
		}
	
		let urlString = tickers
			.map { $0.symbol + "," }
			.reduce(endpoint, +)
			.dropLast()
			.replacingOccurrences(of: "^", with: "%5E")

		request(to: URL(string: String(urlString)), result: result)
	}
	
	// MARK: - Private
	
	private func request(to url: URL?, result: ((TickersResponse) -> Void)?) {
		guard let url = url else {
			result?(.failure(APIError.invalidURL))
			return
		}
		cancellable = URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.decode(type: QuoteResponse.self, decoder: JSONDecoder())
			.eraseToAnyPublisher()
			.receive(on: DispatchQueue.main)
			.sink(receiveCompletion: { completion in
				switch completion {
				case .finished: break
				case .failure(let error):
					NSLog(error.localizedDescription)
				}
			}, receiveValue: { response in
				let tickers = response.quoteResponse.result
					.filter { $0.quote != .unknown }
					.enumerated()
					.compactMap { index, ticker -> Ticker in
						var orderedTicker = ticker
						orderedTicker.orderIndex = index
						return orderedTicker
					}
				result?(.success(tickers))
			})
	}
}
