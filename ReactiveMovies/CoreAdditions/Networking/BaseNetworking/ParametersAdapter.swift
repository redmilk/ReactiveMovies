//
//  ParametersAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

struct Params {
    let title: String
    let value: String?
}

struct RequestParametersAdapter: URLRequestAdaptable {
    
    let parameters: [Params]
    let withBody: Bool
    
    init(withBody: Bool, parameters: [Params]) {
        self.parameters = parameters
        self.withBody = withBody
    }
    
    func adapt(
        _ urlRequest: inout URLRequest
    ) {
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
