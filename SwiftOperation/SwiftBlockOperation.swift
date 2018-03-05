//
//  SwiftBlockOperation.swift
//  SwiftOperation
//
//  Created by Zhu Shengqi on 11/03/2018.
//  Copyright © 2018 Zhu Shengqi. All rights reserved.
//

import Foundation

public final class SwiftBlockOperation: SwiftOperation {
  
  private let block: () -> Void
  
  public init(_ block: @escaping () -> Void) {
    self.block = block
  }
  
  public override func main() {
    block()
  }
  
}
