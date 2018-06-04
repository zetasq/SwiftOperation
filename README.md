# SwiftOperation

A light-weight dependency-operation framework in Swift (inspired by the open sourced **NSOperation** implementation in [swift-corelibs-foundation](https://github.com/apple/swift-corelibs-foundation)

[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

## Installation
### Carthage
To integrate **SwiftOperation** into your Xcode project using [Carthage](https://github.com/Carthage/Carthage), specify it in your `Cartfile`:

```ogdl
github "zetasq/SwiftOperation"
```

Run `carthage update` to build the framework. Drag the built `SwiftOperation.framework` into your Xcode project.

## Usage

**SwiftOperation**'s API is very similar to **NSOperation**, you can add dependencies to an operation, subclass `SwiftOperation` to encapsulate custom logic, etc.

```swift

let queue = SwiftOperationQueue()

let op1 = SwiftBlockOperation({ /* some work */ })
let op2 = SwiftBlockOperation({ /* some work */ })
let op3 = SwiftBlockOperation({ /* some work */ })

op3.addDependency(op1)
op3.addDependency(op2)

queue.isSuspended = true // suspend the queue first before add operations
queue.addOperations([op1, op2, op3])
queue.isSuspended = false // resume the queue to start the operations

```

## License

**SwiftOperation** is released under the MIT license. [See LICENSE](https://github.com/zetasq/SwiftOperation/blob/master/LICENSE) for details.
