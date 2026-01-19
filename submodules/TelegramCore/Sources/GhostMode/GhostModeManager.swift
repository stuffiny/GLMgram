import Foundation

/// GhostModeManager - Central manager for Ghost Mode privacy settings
/// Controls all privacy features: hide read receipts, typing indicator, online status, story views
public final class GhostModeManager {
    
    // MARK: - Singleton
    
    public static let shared = GhostModeManager()
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let isEnabled = "GhostMode.isEnabled"
        static let hideReadReceipts = "GhostMode.hideReadReceipts"
        static let hideStoryViews = "GhostMode.hideStoryViews"
        static let hideOnlineStatus = "GhostMode.hideOnlineStatus"
        static let hideTypingIndicator = "GhostMode.hideTypingIndicator"
        static let forceOffline = "GhostMode.forceOffline"
    }
    
    // MARK: - Settings Storage
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Properties
    
    /// Master toggle for Ghost Mode
    public var isEnabled: Bool {
        get { defaults.bool(forKey: Keys.isEnabled) }
        set { 
            defaults.set(newValue, forKey: Keys.isEnabled)
            notifySettingsChanged()
        }
    }
    
    /// Don't send read receipts (blue checkmarks)
    public var hideReadReceipts: Bool {
        get { defaults.bool(forKey: Keys.hideReadReceipts) }
        set { 
            defaults.set(newValue, forKey: Keys.hideReadReceipts)
            notifySettingsChanged()
        }
    }
    
    /// Don't send story view notifications
    public var hideStoryViews: Bool {
        get { defaults.bool(forKey: Keys.hideStoryViews) }
        set { 
            defaults.set(newValue, forKey: Keys.hideStoryViews)
            notifySettingsChanged()
        }
    }
    
    /// Don't send online status
    public var hideOnlineStatus: Bool {
        get { defaults.bool(forKey: Keys.hideOnlineStatus) }
        set { 
            defaults.set(newValue, forKey: Keys.hideOnlineStatus)
            notifySettingsChanged()
        }
    }
    
    /// Don't send typing indicator
    public var hideTypingIndicator: Bool {
        get { defaults.bool(forKey: Keys.hideTypingIndicator) }
        set { 
            defaults.set(newValue, forKey: Keys.hideTypingIndicator)
            notifySettingsChanged()
        }
    }
    
    /// Always appear as offline
    public var forceOffline: Bool {
        get { defaults.bool(forKey: Keys.forceOffline) }
        set { 
            defaults.set(newValue, forKey: Keys.forceOffline)
            notifySettingsChanged()
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if read receipts should be hidden (master + individual toggle)
    public var shouldHideReadReceipts: Bool {
        return isEnabled && hideReadReceipts
    }
    
    /// Check if story views should be hidden
    public var shouldHideStoryViews: Bool {
        return isEnabled && hideStoryViews
    }
    
    /// Check if online status should be hidden
    public var shouldHideOnlineStatus: Bool {
        return isEnabled && hideOnlineStatus
    }
    
    /// Check if typing indicator should be hidden
    public var shouldHideTypingIndicator: Bool {
        return isEnabled && hideTypingIndicator
    }
    
    /// Check if should force offline
    public var shouldForceOffline: Bool {
        return isEnabled && forceOffline
    }
    
    /// Count of active features (e.g., "5/5")
    public var activeFeatureCount: Int {
        var count = 0
        if hideReadReceipts { count += 1 }
        if hideStoryViews { count += 1 }
        if hideOnlineStatus { count += 1 }
        if hideTypingIndicator { count += 1 }
        if forceOffline { count += 1 }
        return count
    }
    
    /// Total number of features
    public static let totalFeatureCount = 5
    
    // MARK: - Initialization
    
    private init() {
        // Set default values if not set
        if !defaults.bool(forKey: "GhostMode.initialized") {
            defaults.set(true, forKey: "GhostMode.initialized")
            // Default: all features enabled when ghost mode is on
            defaults.set(true, forKey: Keys.hideReadReceipts)
            defaults.set(true, forKey: Keys.hideStoryViews)
            defaults.set(true, forKey: Keys.hideOnlineStatus)
            defaults.set(true, forKey: Keys.hideTypingIndicator)
            defaults.set(true, forKey: Keys.forceOffline)
            // Ghost mode itself is off by default
            defaults.set(false, forKey: Keys.isEnabled)
        }
    }
    
    // MARK: - Enable All
    
    /// Enable all ghost mode features
    public func enableAll() {
        hideReadReceipts = true
        hideStoryViews = true
        hideOnlineStatus = true
        hideTypingIndicator = true
        forceOffline = true
        isEnabled = true
    }
    
    /// Disable all ghost mode features
    public func disableAll() {
        isEnabled = false
    }
    
    // MARK: - Notifications
    
    public static let settingsChangedNotification = Notification.Name("GhostModeSettingsChanged")
    
    private func notifySettingsChanged() {
        NotificationCenter.default.post(name: GhostModeManager.settingsChangedNotification, object: nil)
    }
}
