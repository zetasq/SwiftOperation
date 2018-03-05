//
//  _OperationList.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 08/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

internal struct _OperationList {
  
  internal private(set) var allOps: [SwiftOperation] = []
  
  private var lowPriorityOps: [SwiftOperation] = []
  private var defaultPriorityOps: [SwiftOperation] = []
  private var highPriorityOps: [SwiftOperation] = []
  
  internal mutating func insert(_ operation: SwiftOperation) {
    allOps.append(operation)
    switch operation.priority {
    case .low:
      lowPriorityOps.append(operation)
    case .default:
      defaultPriorityOps.append(operation)
    case .high:
      highPriorityOps.append(operation)
    }
  }
  
  internal mutating func remove(_ operation: SwiftOperation) {
    if let idx = allOps.index(of: operation) {
      allOps.remove(at: idx)
    }
    
    switch operation.priority {
    case .low:
      if let idx = lowPriorityOps.index(of: operation) {
        lowPriorityOps.remove(at: idx)
      }
    case .default:
      if let idx = defaultPriorityOps.index(of: operation) {
        defaultPriorityOps.remove(at: idx)
      }
    case .high:
      if let idx = highPriorityOps.index(of: operation) {
        highPriorityOps.remove(at: idx)
      }
    }
  }
  
  internal mutating func dequeue() -> SwiftOperation? {
    var dequeuedOp: SwiftOperation?
    
    if !highPriorityOps.isEmpty {
      dequeuedOp = highPriorityOps.removeFirst()
    } else if !defaultPriorityOps.isEmpty {
      dequeuedOp = defaultPriorityOps.removeFirst()
    } else if !lowPriorityOps.isEmpty {
      dequeuedOp = lowPriorityOps.removeFirst()
    }
    
    if let op = dequeuedOp {
      if let idx = allOps.index(of: op) {
        allOps.remove(at: idx)
      } else {
        assert(false, "dequeue an operation from priority queue without finding it in allOps")
      }
    }
    
    return dequeuedOp
  }
  
  internal var count: Int {
    return allOps.count
  }
  
}
