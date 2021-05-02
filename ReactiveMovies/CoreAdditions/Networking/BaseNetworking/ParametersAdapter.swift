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

// TODO: refactor params, avoid isBodyMain

struct RequestParametersAdapter: URLRequestAdaptable {
    private let parameters: [Param]
    private let extraQuery: [Param]
    private let isBodyMain: Bool
    private var jsonParameters: [String: String] {
        var jsonParameters: [String: String] = [:]
        parameters.forEach { jsonParameters[$0.key] = $0.value }
        return jsonParameters
    }
    
    init(isBodyMain: Bool,
         parameters: [Param],
         extraQuery: [Param] = []
    ) {
        self.parameters = parameters
        self.isBodyMain = isBodyMain
        self.extraQuery = extraQuery
    }
    
    func adapt(_ urlRequest: inout URLRequest) {
        isBodyMain ?
            adaptRequestWithBody(&urlRequest) :
            adaptRequestWithQuery(&urlRequest, params: parameters)
        print("BEFORE: " + urlRequest.url!.absoluteString)
        guard extraQuery.count > 0 else { return }
        adaptRequestWithQuery(&urlRequest, params: extraQuery)
        print("AFTER: " + urlRequest.url!.absoluteString)
//        let queryItems = extraQuery
//            .filter { $0.value != nil }
//            .map { URLQueryItem(name: $0.key, value: $0.value) }
//
//        var urlComponents = URLComponents(string: urlRequest.url!.absoluteString)
//        //urlComponents?.queryItems?.append(<#T##newElement: URLQueryItem##URLQueryItem#>)
//        urlComponents?.queryItems = queryItems
//        urlRequest.url = urlComponents?.url
//
    }
}

// MARK: - Private

private extension RequestParametersAdapter {
    func adaptRequestWithBody(_ urlRequest: inout URLRequest) {
        guard let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonParameters,
                options: .prettyPrinted) else {
            fatalError("RequestParametersAdapter: JSONSerialization fail")
        }
        
        urlRequest.httpBody = jsonData
    }
    
    func adaptRequestWithQuery(_ urlRequest: inout URLRequest, params: [Param]) {
        guard let url = urlRequest.url,
              var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else { return }
        
        let queryItems = params
            .filter { $0.value != nil }
            .map { URLQueryItem(name: $0.key, value: $0.value) }
        urlComponents.queryItems = urlComponents.queryItems ?? [] + queryItems
        urlRequest.url = urlComponents.url
    }
}
