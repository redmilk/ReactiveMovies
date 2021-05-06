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
        case urlEncoded = "application/x-www-form-urlencoded" //application/x-www-form-urlencoded
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

        urlRequest.setValue(ContentType.jsonUtf8.rawValue, forHTTPHeaderField: Keys.accept)
        urlRequest.setValue("B4750362-BE52-402E-811D-ECB25FCA72C3", forHTTPHeaderField: Keys.deviceId)
        urlRequest.setValue("5.8", forHTTPHeaderField: Keys.appVersion)
        urlRequest.setValue("ios", forHTTPHeaderField: Keys.appPlatform)
        urlRequest.setValue("iPhone 11", forHTTPHeaderField: Keys.deviceModel)
        urlRequest.setValue("14.4", forHTTPHeaderField: Keys.platformVerion)
    }
}
