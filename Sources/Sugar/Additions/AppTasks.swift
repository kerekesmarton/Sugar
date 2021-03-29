import UIKit

public protocol AppTaskable: UIWindowSceneDelegate, UIApplicationDelegate {}

open class AppTask: AsyncOperaiton, AppTaskable {
    public override init() {
        super.init()
    }
}

public protocol ServiceProvider {
    func modules() -> [Register]
    var appTasks: [AppTask] { get }
}

open class AppTasks {

    public static var shared: AppTasks?
    public static func build(serviceProviders: [ServiceProvider], finished: @escaping Action) -> AppTasks {
        let tasks = AppTasks(serviceProviders, finished: finished)
        shared = tasks
        return tasks
    }

    @Inject private var dispatch: Dispatching
    let queue = OperationQueue()
    open var serviceProviders = [ServiceProvider]()

    private lazy var allTasks: [AppTask] = {
        serviceProviders.compactMap { $0.appTasks }.reduce([AppTask]()) { (result, next) in
            return result + next
        }
    }()

    private init(_ serviceProviders: [ServiceProvider], finished: @escaping Action) {
        self.serviceProviders = serviceProviders
        CoreServiceLocator.shared.add { () -> [ServiceProvider] in
            serviceProviders
        }

        queue.addOperations(allTasks, waitUntilFinished: false)
        queue.addBarrierBlock {
            self.dispatch.dispatchMain {
                finished()
                self.isReady = true
            }
        }

    }

    var isReady: Bool = false {
        didSet {
            if isReady {
                allSatisfyBuffer.forEach {
                    _ = try? allSatisfy($0)
                }
                allSatisfyBuffer.removeAll()

                forEachBuffer.forEach {
                    try? forEach($0)
                }
                forEachBuffer.removeAll()
            }
        }
    }

    var forEachBuffer = [(AppTaskable) throws -> Void]()
    public func forEach(_ body: @escaping (AppTaskable) throws -> Void) rethrows {
        guard isReady else {
            forEachBuffer.append(body)
            return
        }

        try allTasks.forEach(body)
    }

    var allSatisfyBuffer = [(AppTaskable) throws -> Bool]()
    public func allSatisfy(_ predicate: @escaping(AppTaskable) throws -> Bool) rethrows -> Bool {
        guard isReady else {
            allSatisfyBuffer.append(predicate)
            return true
        }
        return try allTasks.allSatisfy(predicate)
    }
}
