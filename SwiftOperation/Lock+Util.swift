//
//  Lock+Util.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 07/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

extension NSLock {
  
  func withCriticalScope<T>(_ block: () throws -> T) rethrows -> T {
    self.lock()
    defer {
      self.unlock()
    }
    return try block()
  }
  
}

extension NSRecursiveLock {
  
  func withCriticalScope<T>(_ block: () throws -> T) rethrows -> T {
    self.lock()
    defer {
      self.unlock()
    }
    return try block()
  }
  
}
