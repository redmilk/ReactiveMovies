//
//  AppDelegate.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 11.04.2021.
//

import Combine
import UIKit

var subscriptions = Set<AnyCancellable>()
var refreshToken: String? = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiItTV8xUldUa1NBNzg5ZHlORDlOUyIsInR5cGUiOiJyZWZyZXNoX3Rva2VuIiwiaWF0IjoxNjIwMzMyODc3LCJleHAiOjE2NTE4Njg4Nzd9.yoZTMWZl9C6EI1RFmT-iyF2wYuQ2dEH6Ii_PjPYr_5o"
var accessToken: TokenRefresh =  TokenRefresh(accessToken: "werqwerqwer", expiresIn: 287463, firebaseToken: nil) {
    didSet {
        Logger.log(accessToken.accessToken, type: .token)
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let httpClient = HTTPClient(session: URLSession(configuration: .ephemeral))
        let claweeAuth = ClaweeAuthApi(httpClient: httpClient)
        
        claweeAuth.requestMachineTypes(token: accessToken.accessToken)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: Logger.log("requestMachineTypes", type: .subscriptionFinished)
                case .failure(let error):
                    Logger.log(error.localizedDescription)
                }
            }, receiveValue: { machineTypes in
                Logger.log("🎉🎉🎉🎉")
            })
            .store(in: &subscriptions)
        
        
        return true
    }
    
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}

