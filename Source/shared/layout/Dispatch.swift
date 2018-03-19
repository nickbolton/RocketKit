//
//  Dispatch.swift
//  RocketKit
//
//  Created by Nick Bolton on 3/16/18.
//

import UIKit

typealias DispatchWorker = ((Int)->Void)

extension DispatchQueue {
    
    static func dispatchGroupAsyncIfNeeded(iterationCount: Int, forced: Bool, worker: @escaping DispatchWorker) {
        if (iterationCount == 0) {
            return;
        }
        
        if (iterationCount == 1) {
            worker(0);
            return;
        }
        
        // TODO Once the locking situation in ASDisplayNode has improved, always dispatch if on main
        if forced || Thread.current.isMainThread {
            groupAsync(iterationCount: iterationCount, threadCountIn: 0, worker: worker)
            return;
        }
        
        for i in 0..<iterationCount {
            worker(i)
        }
    }
    
    static func groupAsync(iterationCount: Int, threadCountIn: Int, worker: @escaping DispatchWorker) {
        let threadCount = threadCountIn > 0 ? threadCountIn : ProcessInfo.processInfo.activeProcessorCount * 2
        let group = DispatchGroup()
        var counter : Int32 = 0
        for _ in 0..<threadCount {
            DispatchQueue.global(qos: .userInitiated).async(group:group) {
                var iteration: Int = 0
                repeat {
                    worker(iteration)
                    iteration = Int(OSAtomicIncrement32(&counter))
                } while Int(iteration) < iterationCount
            }
        }
        group.wait()
    }
    
    /**
     * Like dispatch_async, but you can set the thread count. 0 means 2*active CPUs.
     *
     * Note: The actual number of threads may be lower than threadCount, if libdispatch
     * decides the system can't handle it. In reality this rarely happens.
     */
        
    static func async(iterationCount: Int, threadCountIn: Int, worker: @escaping DispatchWorker) {
        let threadCount = threadCountIn > 0 ? threadCountIn : ProcessInfo.processInfo.activeProcessorCount * 2
        let group = DispatchGroup()
        var counter : Int32 = 0
        for _ in 0..<threadCount {
            DispatchQueue.global(qos: .userInitiated).async {
                var iteration: Int = 0
                repeat {
                    worker(iteration+1)
                    iteration = Int(OSAtomicIncrement32(&counter))
                } while Int(iteration) < iterationCount
            }
        }
    }
}
