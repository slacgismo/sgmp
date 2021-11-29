import Foundation

extension Bundle {
    
    /// App's version
    var versionString: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    /// App's build
    var buildString: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
    /// App's display name
    var displayName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }
}
