//
//  OrderedSet.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 04/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public struct OrderedSet<Element: Hashable> {
  // MARK: - Properties
  private var _storage: OrderedSetRef<Element>
  
  // MARK: - Init & deinit
  public init() {
    _storage = OrderedSetRef<Element>()
  }
  
  // MARK: - Public methods
  public mutating func append(_ element: Element) {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
    }
    
    _storage.append(element)
  }
  
  public mutating func remove(_ element: Element) {
    if !isKnownUniquelyReferenced(&_storage) {
      _storage = _storage.copy()
    }
    
    _storage.remove(element)
  }
  
  public var first: Element? {
    return _storage.first
  }
  
  public var last: Element? {
    return _storage.last
  }
  
  public func contains(_ element: Element) -> Bool {
    return _storage.contains(element)
  }

}

extension OrderedSet: Sequence {
  
  public func makeIterator() -> AnyIterator<Element> {
    return _storage.makeIterator()
  }
  
}
