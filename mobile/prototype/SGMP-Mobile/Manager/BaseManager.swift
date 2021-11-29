import Foundation

/// Base class for all singletons that can be woken up with a `setupAllBaseManagers()` call
public class BaseManager : NSObject {
    
    /// Access the singleton instance from static methods. Needs to be overriden in subclasses and return its own class type
    class var shared : BaseManager {
        return BaseManager()
    }
    
    func setup() -> Void {
        
    }
    
    func destroy() -> Void {
        
    }
}


/// Use runtime reflection to wake up all subclasses of `BaseManager` by calling the `BaseManager.setup()` function
/// - Returns: void
public func setupAllBaseManagers() -> Void {
    let list = subclasses(of: BaseManager.self)
    list.forEach { (manager) in
        manager.shared.setup()
    }
}


public func destroyAllBaseManagers() -> Void {
    let list = subclasses(of: BaseManager.self)
    list.forEach { (manager) in
        manager.shared.destroy()
    }
}
