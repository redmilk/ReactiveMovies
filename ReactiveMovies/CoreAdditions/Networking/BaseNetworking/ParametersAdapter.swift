//
//  ParametersAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

struct Param {
    let key: String
    let value: CustomStringConvertible?

    init(_ key: String, _ value: CustomStringConvertible?) {
        self.key = key
        self.value = value
    }
}

struct RequestParametersAdapter: URLRequestAdaptable {
    private let query: [Param]
    private let body: [Param]
    private var bodyJson: [String: CustomStringConvertible] {
        var jsonParameters: [String: CustomStringConvertible] = [:]
        body.forEach { jsonParameters[$0.key] = $0.value }
        return jsonParameters
    }

    // MARK: - API
    
    init(query: [Param] = [], body: [Param] = []) {
        self.query = query
        self.body = body
    }

    func adapt(_ urlRequest: inout URLRequest) {
        adaptRequestWithBody(&urlRequest)
        adaptRequestWithQuery(&urlRequest)
    }
}

// MARK: - Private

private extension RequestParametersAdapter {
    func adaptRequestWithBody(_ urlRequest: inout URLRequest) {
        guard !bodyJson.isEmpty else { return }
        guard let jsonData = try? JSONSerialization.data(
                withJSONObject: bodyJson,
                options: .prettyPrinted) else {
            fatalError("RequestParametersAdapter: JSONSerialization fail")
        }
        
        urlRequest.httpBody = jsonData
    }
    
    func adaptRequestWithQuery(_ urlRequest: inout URLRequest) {
        guard let url = urlRequest.url,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }
        
        let queryItems = query
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.key, value: $0.value?.description) }
        urlComponents.queryItems = urlComponents.queryItems ?? [] + queryItems
        urlRequest.url = urlComponents.url
    }
}
