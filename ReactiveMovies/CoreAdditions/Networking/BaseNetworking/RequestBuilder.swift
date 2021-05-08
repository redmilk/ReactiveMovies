//
//  RequestBuilder.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
    case head = "HEAD"
}

struct RequestBuilder {

    private let baseUrl: URL
    private let pathComponent: String
    private let adapters: [URLRequestAdaptable]
    private let method: HTTPMethod
    private let timeoutInterval: TimeInterval
    
    lazy var request: URLRequest = {
        let url = baseUrl.appendingPathComponent(pathComponent)
        var request = URLRequest(url: url)
        adapters.forEach { $0.adapt(&request) }
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        return request
    }()
    
    init(baseUrl: URL,
         pathComponent: String,
         adapters: [URLRequestAdaptable],
         method: HTTPMethod,
         timoutInterval: TimeInterval = 10.0
    ) {
        self.baseUrl = baseUrl
        self.pathComponent = pathComponent
        self.adapters = adapters
        self.method = method
        self.timeoutInterval = timoutInterval
    }
}
