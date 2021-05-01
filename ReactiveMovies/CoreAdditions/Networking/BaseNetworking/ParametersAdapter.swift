//
//  ParametersAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

struct Param {
    let key: String
    let value: String?

    init(_ key: String, _ value: String?) {
        self.key = key
        self.value = value
    }
}

struct RequestParametersAdapter: URLRequestAdaptable {
    private let parameters: [Param]
    private let withBody: Bool
    
    init(withBody: Bool, parameters: [Param]) {
        self.parameters = parameters
        self.withBody = withBody
    }
    
    func adapt(_ urlRequest: inout URLRequest) {
        withBody ? adaptRequestWithBody(&urlRequest) : adaptRequestWithQuery(&urlRequest)
    }
}

// MARK: - Private

private extension RequestParametersAdapter {
    func adaptRequestWithBody(_ urlRequest: inout URLRequest) {
        guard let jsonData = try? JSONSerialization.data(
                withJSONObject: parameters,
                options: .prettyPrinted) else {
            fatalError("RequestParametersAdapter: JSONSerialization fail")
        }
        
        urlRequest.httpBody = jsonData
    }
    
    func adaptRequestWithQuery(_ urlRequest: inout URLRequest) {
        guard let url = urlRequest.url,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }
        
        let queryItems = parameters
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = urlComponents.queryItems ?? [] + queryItems
        urlRequest.url = urlComponents.url
    }
}
