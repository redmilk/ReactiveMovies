//
//  ParametersAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

typealias RequestParameter = (title: String, value: String?)

struct RequestParametersAdapter: URLRequestAdaptable {
    
    let parameters: [RequestParameter]
    let withBody: Bool
    
    init(withBody: Bool, parameters: [RequestParameter]) {
        self.parameters = parameters
        self.withBody = withBody
    }
    
    func adapt(_ urlRequest: inout URLRequest) {
        if !withBody {
            guard let url = urlRequest.url,
                  var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true) else { return }
            let queryItems = parameters
                .filter { $0.value != nil }
                .map { URLQueryItem(name: $0.title, value: $0.value) }
            urlComponents.queryItems = urlComponents.queryItems ?? [] + queryItems
            urlRequest.url = urlComponents.url
        } else {
            guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters,
                                                             options: .prettyPrinted) else {
                fatalError("RequestParametersAdapter: JSONSerialization fail")
            }
            urlRequest.httpBody = jsonData
        }
    }
    
}
