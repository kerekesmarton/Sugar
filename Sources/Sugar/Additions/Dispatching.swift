import Foundation

public typealias Action = () -> Void

public protocol Dispatching {
    func dispatchMain(block: @escaping Action)
    func dispatchMain(after seconds: Int, block: @escaping Action)
    func block(_ block: @escaping Action)
    func dispatch(after seconds: Int, queue: DispatchQueue, block: @escaping Action)

    func onMain<T>(result: T, completion: @escaping (T) -> Void)
}

public struct Dispatcher: Dispatching {
    public init() {}
    public func dispatchMain(block: @escaping Action) {
        DispatchQueue.main.async(execute: block)
    }
    
    public func dispatchMain(after seconds: Int = 0, block: @escaping Action) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds), execute: block)
    }

    public func block(_ block: @escaping Action) {
        dispatch(queue: DispatchQueue.global(), block: block)
    }
    
    public func dispatch(queue: DispatchQueue, block: @escaping Action) {
        queue.async(execute: block)
    }
    
    public func dispatch(after seconds: Int = 0, queue: DispatchQueue, block: @escaping Action) {
        queue.asyncAfter(deadline: .now() + .seconds(seconds), execute: block)
    }

    public func onMain<T>(result: T, completion: @escaping (T) -> Void) {
        dispatchMain {
            completion(result)
        }
    }
}

public struct MockDispatcher: Dispatching {
    public init() {}
    public func dispatchMain(block: @escaping Action) {
        block()
    }
    
    public func dispatchMain(after seconds: Int, block: @escaping Action) {
        block()
    }
    
    public func block(_ block: @escaping Action) {
        block()
    }
    
    public func dispatch(after seconds: Int, queue: DispatchQueue, block: @escaping Action) {
        block()
    }

    public func onMain<T>(result: T, completion: @escaping (T) -> Void) {
        completion(result)
    }
}
