import Foundation
//based on https://github.com/ZamzamInc/Shank

/// A dependency collection that provides resolutions for object instances.
public class CoreServiceLocator {
    private init() {}
    deinit { services.removeAll() }
    public static var shared = CoreServiceLocator()

    /// Stored object instance factories.
    private var services = [String: Register]()

    public func add(@Builder modules: () -> [Register]) {
        modules().forEach {
            services[$0.name] = $0
        }
    }

    public func addBuildTasks(_ buildTasks: () -> [ServiceProvider]) {
        buildTasks().forEach { (task) in
            task.modules().forEach {
                services[$0.name] = $0                
            }
        }
    }

    /// Resolves through inference and returns an instance of the given type from the current default container.
    ///
    /// If the dependency is not found, an exception will occur.
    func resolve<T>(for name: String? = nil) -> T {
        let name = name ?? String(describing: T.self)
        
        guard let component: T = services[name]?.resolve() as? T else {
            fatalError("Dependency '\(T.self)' not resolved!")
        }
        
        return component
    }
}

// MARK: Public API
public extension CoreServiceLocator {
    @resultBuilder struct Builder {
        public static func buildBlock(_ modules: Register...) -> [Register] { modules }
        public static func buildBlock(_ module: Register) -> Register { module }
    }
}

/// A type that contributes to the object graph.
public struct Register {
    fileprivate let name: String
    fileprivate let resolve: () -> Any
    
    public init<T>(_ type: T.Type = T.self, _ resolve: @escaping () -> T) {
        self.name = String(describing: T.self)
        self.resolve = resolve
    }
}

/// Resolves an instance from the dependency injection container.
@propertyWrapper
public class Inject<Value>: ObservableObject {
    private let name: String?
    private var storage: Value?
    
    public var wrappedValue: Value {
        storage ?? {
            let value: Value = CoreServiceLocator.shared.resolve(for: name)
            storage = value // Reuse instance for later
            return value
        }()
    }
    
    public init() {
        self.name = nil
    }
    
    public init<Value>(_ type: Value.Type = Value.self) {
        self.name = String(describing: Value.self)
    }
}
