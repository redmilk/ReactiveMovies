//
//  HeaderAdapter.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Foundation

protocol URLRequestAdaptable {
    func adapt(_ urlRequest: inout URLRequest)
}

final class RequestHeaderAdapter: URLRequestAdaptable {
    
    enum ContentType: String {
        case json = "application/json"
        case jsonUtf8 = "application/json; charset=utf-8"
        case formData = "multipart/form-data"
        case urlEncoded = "application/x-www-form-urlencoded"
    }

    private let headers: [(String, String)]
    
    init(headers: [(String, String)] = [], contentType: ContentType = .jsonUtf8) {
        self.headers = headers
    }

    func adapt(_ urlRequest: inout URLRequest) {
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        urlRequest.setValue(ContentType.jsonUtf8.rawValue, forHTTPHeaderField: "Content-Type")
        headers.forEach { urlRequest.setValue($0.1, forHTTPHeaderField: $0.0) }
    }
}
