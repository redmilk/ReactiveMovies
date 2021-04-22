//
//  Schedulers.swift
//  ReactiveMovies
//
//  Created by Danyl Timofeyev on 22.04.2021.
//

import Foundation

final class Scheduler {

    static var backgroundWorkScheduler: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 5
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return operationQueue
    }()

    static let mainScheduler = RunLoop.main
    
}
