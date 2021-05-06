//
//  ClaweeModels.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 06.05.2021.
//

import Foundation

// MARK: - User
struct User: Codable {
    let firebaseToken: String?
    let accessToken: String?
    let refreshToken: String?
    let expiresIn: Int?
    let user: UserClass?

    enum CodingKeys: String, CodingKey {
        case firebaseToken = "firebaseToken"
        case accessToken = "accessToken"
        case refreshToken = "refreshToken"
        case expiresIn = "expiresIn"
        case user = "user"
    }
}

// MARK: - UserClass
struct UserClass: Codable {
    let id: String?
    let avatar: String?
    let email: String?
    let name: String?
    let flags: Flags?
    let roles: Roles?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case avatar = "avatar"
        case email = "email"
        case name = "name"
        case flags = "flags"
        case roles = "roles"
    }
}

// MARK: - Flags
struct Flags: Codable {
    let didClaim: Bool?
    let didExchange: Bool?
    let didPay: Bool?
    let isDeveloper: Bool?
    let isInternal: Bool?
    let isAdmin: Bool?

    enum CodingKeys: String, CodingKey {
        case didClaim = "didClaim"
        case didExchange = "didExchange"
        case didPay = "didPay"
        case isDeveloper = "isDeveloper"
        case isInternal = "isInternal"
        case isAdmin = "isAdmin"
    }
}

// MARK: - Roles
struct Roles: Codable {
    let superUser: Bool?
    let operationUser: Bool?
    let dashboardUser: Bool?
    let observerUser: Bool?
    let customerSupportUser: Bool?
    let exportData: Bool?

    enum CodingKeys: String, CodingKey {
        case superUser = "super_user"
        case operationUser = "operation_user"
        case dashboardUser = "dashboard_user"
        case observerUser = "observer_user"
        case customerSupportUser = "customer_support_user"
        case exportData = "export_data"
    }
}


// MARK: - Machine Types
struct MachineTypes: Decodable {
    let items: [MachineType]
}

struct MachineType: Decodable {
    let type: String
    let image: String
}

// Token Refresh
struct TokenRefresh: Codable {
    let accessToken: String
    let expiresIn: Int
    let firebaseToken: String?
    
    var isExpired: Bool {
        Logger.log("Current date \(Date()), Expiration date \(expirationDate)")
        return Date() > expirationDate
    }
    
    private var expirationDate: Date {
        let currentDateInterval = Date().timeIntervalSince1970
        let expirationDateInterval = currentDateInterval + Double(expiresIn) / 1000.0
        return Date(timeIntervalSince1970: expirationDateInterval)
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "accessToken"
        case expiresIn = "expiresIn"
        case firebaseToken = "firebaseToken"
    }
}
