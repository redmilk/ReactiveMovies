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

struct RequestHeaderAdapter: URLRequestAdaptable {
    
    enum ContentType: String {
        case json = "application/json"
        case jsonUtf8 = "application/json; charset=utf-8"
        case formData = "multipart/form-data"
        case urlEncoded = "application/x-www-form-urlencoded"
    }
    
    private enum Keys {
        static let accept = "Accept"
        static let authorization = "Authorization"
        static let contentType = "Content-Type"
        static let deviceId = "X-User-DeviceId"
        static let appVersion = "X-App-Version"
        static let appPlatform = "X-Device-Platform"
        static let deviceModel = "X-Device-Model"
        static let platformVerion = "X-Device-Platform-Version"
    }

    private var headers: [(String, String)]
    
    init(headers: [(String, String)] = [], contentType: ContentType = .jsonUtf8) {
        self.headers = headers
        self.headers.append(("Content-Type", contentType.rawValue))
    }

    func adapt(_ urlRequest: inout URLRequest) {
        urlRequest.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
        headers.forEach { urlRequest.setValue($0.1, forHTTPHeaderField: $0.0) }
    }
}
