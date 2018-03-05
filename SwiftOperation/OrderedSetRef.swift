//
//  OrderedSetRef.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 04/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation


public final class OrderedSetRef<Element: Hashable> {
  // MARK: - Internal types
  private final class Entry<T: Hashable>: Hashable {
    
    weak var pre: Entry<T>?
    weak var succ: Entry<T>?
    
    let val: T
    
    init(val: T) {
      self.val = val
    }
    
    static func ==(lhs: Entry<T>, rhs: Entry<T>) -> Bool {
      return lhs.val == rhs.val
    }
    
    var hashValue: Int {
      return val.hashValue
    }
    
  }
  
  // MARK: - Properties
  private var set: Set<Entry<Element>> = []
  
  private var headEntry: Entry<Element>?
  private var tailEntry: Entry<Element>?
  
  // MARK: - Init & deinit
  init() {}
  
  // MARK: - Public methods
  public func append(_ element: Element) {
    let entry = Entry(val: element)
    set.insert(entry)
    
    if let tailEntry = tailEntry {
      entry.pre = tailEntry
      tailEntry.succ = entry
      self.tailEntry = entry
    } else {
      self.headEntry = entry
      self.tailEntry = entry
    }
  }
  
  public func remove(_ element: Element) {
    let entry = Entry(val: element)
    guard let removedEntry = set.remove(entry) else {
      return
    }
    
    let pre = removedEntry.pre
    let succ = removedEntry.succ
    
    if let preEntry = pre {
      preEntry.succ = succ
    } else {
      headEntry = succ
    }
    
    if let succEntry = succ {
      succEntry.pre = pre
    } else {
      tailEntry = pre
    }
  }
  
  public var first: Element? {
    return headEntry?.val
  }
  
  public var last: Element? {
    return tailEntry?.val
  }
  
  public func copy() -> OrderedSetRef<Element> {
    let newStorage = OrderedSetRef<Element>()
    
    for element in self {
      newStorage.append(element)
    }
    
    return newStorage
  }
  
  public func contains(_ element: Element) -> Bool {
    let entry = Entry(val: element)
    return set.contains(entry)
  }

}

extension OrderedSetRef: Sequence {
  
  public func makeIterator() -> AnyIterator<Element> {
    var head = headEntry
    return AnyIterator({
      let element = head?.val
      head = head?.succ
      return element
    })
  }
  
}

