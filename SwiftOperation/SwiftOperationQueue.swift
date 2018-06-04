//
//  SwiftOperationQueue.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 04/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class SwiftOperationQueue {
  
  public static let defaultMaxConcurrentOperationCount = ProcessInfo().processorCount
  
  public static let `default`: SwiftOperationQueue = {
    let dispatchQueue = DispatchQueue(label: "SwiftOperationQueue::default::underlyingQueue", attributes: [.concurrent, .initiallyInactive])
    dispatchQueue.setTarget(queue: DispatchQueue.global(qos: .default))
    dispatchQueue.resume()
    
    return SwiftOperationQueue(queue: dispatchQueue)
  }()
  
  public static let main: SwiftOperationQueue = {
    let dispatchQueue = DispatchQueue(label: "SwiftOperationQueue::main::underlyingQueue", attributes: [.concurrent, .initiallyInactive])
    dispatchQueue.setTarget(queue: DispatchQueue.main)
    dispatchQueue.resume()

    return SwiftOperationQueue(queue: dispatchQueue, maxConcurrentOperationCount: 1)
  }()
  
  private let lock = NSLock()
  
  private let _underlyingQueue: DispatchQueue
  private let _concurrencySemaphore: DispatchSemaphore
  private var _operationPriorityQueue = _OperationList()
  
  private var _isSuspended = false
  
  public init(queue: DispatchQueue = DispatchQueue(label: "SwiftOperationQueue::custom::underlyingQueue", attributes: .concurrent), maxConcurrentOperationCount: Int = SwiftOperationQueue.defaultMaxConcurrentOperationCount) {
    assert(maxConcurrentOperationCount > 0)
    self._underlyingQueue = queue
    self._concurrencySemaphore = DispatchSemaphore(value: maxConcurrentOperationCount)
  }
  
  public var isSuspended: Bool {
    get {
      return lock.withCriticalScope {
        return _isSuspended
      }
    }
    set {
      lock.withCriticalScope {
        guard _isSuspended != newValue else {
          // DispatchQueue's suspend() and resume() calls must be balanced. We should not suspend an already suspended DispatchQueue.
          return
        }
        
        _isSuspended = newValue
        if newValue {
          _underlyingQueue.suspend()
        } else {
          _underlyingQueue.resume()
        }
      }
    }
  }
  
  public func addOperations(_ operations: [SwiftOperation]) {
    lock.withCriticalScope {
      for op in operations {
        op._queue = self
        _operationPriorityQueue.insert(op)
      }
    }
    
    for _ in operations {
      _underlyingQueue.async {
        self._concurrencySemaphore.wait()
        self._runOperation()
      }
    }
  }
  
  public func addOperation(_ operation: SwiftOperation) {
    addOperations([operation])
  }
  
  private func _dequeueOperation() -> SwiftOperation? {
    return lock.withCriticalScope {
      return _operationPriorityQueue.dequeue()
    }
  }
  
  private func _runOperation() {
    guard let op = _dequeueOperation() else {
      return
    }
    
    op._waitUntilReady()
    op.start()
  }
  
  internal func _operationFinished(_ operation: SwiftOperation) {
    lock.withCriticalScope {
      _operationPriorityQueue.remove(operation)
      operation._queue = nil
    }
    _concurrencySemaphore.signal()
  }
  
  public func cancelAllOperations() {
    let ops = lock.withCriticalScope {
      return _operationPriorityQueue.allOps
    }
    
    ops.forEach { $0.isCanceled = true }
  }
  
}
