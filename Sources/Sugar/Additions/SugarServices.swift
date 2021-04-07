import Foundation

public class SugarServices: ServiceProvider {
    public init(){}
    public var appTasks = [AppTask]()
    public func modules() -> [Register] {
        [
            Register(Dispatching.self) { Dispatcher() },
            //Storage
            Register { LocalKeyValueStorage() },
        ]
    }
}
