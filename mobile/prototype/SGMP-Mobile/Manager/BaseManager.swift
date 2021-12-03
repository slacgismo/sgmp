import Foundation

/**
 Base class for all singletons that can be woken up with a `setupAllBaseManagers()` call
 */
public class BaseManager : NSObject {
    
    /// Access the singleton instance from static methods. Needs to be overriden in subclasses and return its own class type
    class var shared : BaseManager {
        return BaseManager()
    }
    
    /// Setup function, sub classes should override and provide their own implementation
    /// - Returns: `Void`
    func setup() -> Void {
        
    }
    
    func destroy() -> Void {
        
    }
}


/// Use runtime reflection to wake up all subclasses of `BaseManager` by calling the `BaseManager.setup()` function
/// - Returns: `Void`
public func setupAllBaseManagers() -> Void {
    let list = subclasses(of: BaseManager.self)
    list.forEach { (manager) in
        manager.shared.setup()
    }
}


/// Use runtime reflection to wake up all subclasses of `BaseManager` by calling the `BaseManager.destroy()` function
/// - Returns: `Void`
public func destroyAllBaseManagers() -> Void {
    let list = subclasses(of: BaseManager.self)
    list.forEach { (manager) in
        manager.shared.destroy()
    }
}
