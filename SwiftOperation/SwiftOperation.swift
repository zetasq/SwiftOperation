//
//  SwiftOperation.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 04/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

open class SwiftOperation {
  
  public enum State {
    case pending
    case ready
    case executing
    case finished
  }
  
  public enum Priority {
    case low
    case `default`
    case high
  }
  
  public let priority: Priority
  
  private let lock = NSLock()
  
  internal final weak var _queue: SwiftOperationQueue?
  private var _state: State = .pending
  private var _isCanceled = false
  private var _dependencies = Set<SwiftOperation>()
  
  private var _ownGroup = DispatchGroup() // This is used to control the operation's own progress
  private var _dependencyObservationGroup = DispatchGroup() // This is used to to be notified when the operation's dependencies are finished
  private var _dependentOperationNotificationGroups = [DispatchGroup]() // This is used to notify those operations which are dependent on this operation
  
  public init(priority: Priority = .default) {
    self.priority = priority
    _ownGroup.enter()
  }
  
  open func start() {
    assert(state == .ready)
    
    state = .executing

    if !isCanceled {
      main()
    }
    finish()
  }
  
  open func main() {}
  
  public final func finish() {
    assert(state == .executing)
    
    lock.withCriticalScope {
      _state = .finished
      _dependentOperationNotificationGroups.forEach { $0.leave() }
      _dependentOperationNotificationGroups.removeAll()
      _ownGroup.leave()
    }
    
    _queue?._operationFinished(self)
  }
  
  public final var state: State {
    get {
      return lock.withCriticalScope {
        return _state
      }
    }
    set {
      return lock.withCriticalScope {
        _state = newValue
      }
    }
  }

  public final var isCanceled: Bool {
    get {
      return lock.withCriticalScope {
        return _isCanceled
      }
    }
    set {
      lock.withCriticalScope {
        _isCanceled = newValue
      }
    }
  }
  
  public final func addDependency(_ op: SwiftOperation) {
    lock.withCriticalScope {
      _dependencies.insert(op)
      _dependencyObservationGroup.enter()
      
      op.lock.withCriticalScope {
        op._dependentOperationNotificationGroups.append(_dependencyObservationGroup)
      }
    }
  }
  
  public final func removeDependency(_ op: SwiftOperation) {
    lock.withCriticalScope {
      _dependencies.remove(op)
      
      op.lock.withCriticalScope {
        if let groupIndex = op._dependentOperationNotificationGroups.index(where: { $0 == _dependencyObservationGroup}) {
          let group = op._dependentOperationNotificationGroups.remove(at: groupIndex)
          group.leave()
        }
      }
    }
  }
  
  internal final func _waitUntilReady() {
    assert(state == .pending)
    
    _dependencyObservationGroup.wait()
    state = .ready
  }
 
}

extension SwiftOperation: Hashable {
  public static func ==(lhs: SwiftOperation, rhs: SwiftOperation) -> Bool {
    return lhs === rhs
  }
  
  public var hashValue: Int {
    return ObjectIdentifier(self).hashValue
  }
}

