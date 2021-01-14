//
//  APIService.swift
//  marketbar
//
//  Created by Daniil Manin on 27.12.2020.
//

import Combine
import Foundation

typealias TickersResponce = Result<[Ticker], Error>

final class APIService {
	
	private var cancellable: AnyCancellable?
	private let endpoint: String = "https://query1.finance.yahoo.com/v7/finance/quote?symbols="
	
	func add(tickerString: String, result: @escaping (TickersResponce) -> Void) {
		let ticker = Ticker(symbol: tickerString, name: "", price: 0.0, previousClose: 0.0)
		update(tickers: [ticker], result: result)
	}
	
	func update(tickers: [Ticker], result: @escaping (TickersResponce) -> Void) {
		guard !tickers.isEmpty else {
			result(.failure(APIError.emptyRequest))
			return
		}
	
		let urlString = tickers
			.map { $0.symbol + "," }
			.reduce(endpoint, +)
			.dropLast()

		request(to: URL(string: String(urlString)), result: result)
	}
	
	// MARK: - Private
	
	private func request(to url: URL?, result: ((TickersResponce) -> Void)?) {
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
				let tickers = response.quoteResponse.result.filter { $0.quote != .unknown }
				result?(.success(tickers))
			})
	}
}
