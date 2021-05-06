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
    private let isFormUrlEncoded: Bool
    private var bodyJson: [String: CustomStringConvertible] {
        var jsonParameters: [String: CustomStringConvertible] = [:]
        body.forEach { jsonParameters[$0.key] = $0.value }
        return jsonParameters
    }

    // MARK: - API
    
    init(query: [Param] = [], body: [Param] = [], isFormUrlEncoded: Bool = false) {
        self.query = query
        self.body = body
        self.isFormUrlEncoded = isFormUrlEncoded
    }

    func adapt(_ urlRequest: inout URLRequest) {
        if body.count > 0 {
            isFormUrlEncoded ? adaptRequestWithBodyURLEncoded(&urlRequest) : adaptRequestWithBody(&urlRequest)
        }
        if query.count > 0 {
            adaptRequestWithQuery(&urlRequest)
        }
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
    
    func adaptRequestWithBodyURLEncoded(_ urlRequest: inout URLRequest) {
        var urlFormDataComponents = URLComponents()
        let queryItems = body
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.key, value: $0.value?.description) }
        urlFormDataComponents.queryItems = queryItems
        let data = urlFormDataComponents.query?.data(using: .utf8)
        urlRequest.httpBody = data
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
