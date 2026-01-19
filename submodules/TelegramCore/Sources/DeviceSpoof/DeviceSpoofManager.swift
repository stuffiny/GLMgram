import Foundation

/// DeviceSpoofManager - Manages device identity spoofing
/// Allows changing device model and system version reported to Telegram servers
public final class DeviceSpoofManager {
    public static let shared = DeviceSpoofManager()
    
    // MARK: - Device Profile
    
    public struct DeviceProfile: Equatable {
        public let id: Int
        public let name: String
        public let deviceModel: String
        public let systemVersion: String
        
        public init(id: Int, name: String, deviceModel: String, systemVersion: String) {
            self.id = id
            self.name = name
            self.deviceModel = deviceModel
            self.systemVersion = systemVersion
        }
    }
    
    // MARK: - Preset Profiles
    
    public static let profiles: [DeviceProfile] = [
        DeviceProfile(id: 0, name: "Реальное устройство", deviceModel: "", systemVersion: ""),
        DeviceProfile(id: 1, name: "iPhone 14 Pro", deviceModel: "iPhone 14 Pro", systemVersion: "iOS 17.2"),
        DeviceProfile(id: 2, name: "iPhone 15 Pro Max", deviceModel: "iPhone 15 Pro Max", systemVersion: "iOS 17.4"),
        DeviceProfile(id: 3, name: "Samsung Galaxy S23", deviceModel: "Samsung SM-S918B", systemVersion: "Android 14"),
        DeviceProfile(id: 4, name: "Google Pixel 8", deviceModel: "Google Pixel 8 Pro", systemVersion: "Android 14"),
        DeviceProfile(id: 5, name: "Desktop Windows", deviceModel: "PC 64bit", systemVersion: "Windows 11"),
        DeviceProfile(id: 6, name: "Desktop macOS", deviceModel: "MacBook Pro", systemVersion: "macOS 14.3"),
        DeviceProfile(id: 7, name: "Telegram Web", deviceModel: "Web", systemVersion: "Chrome 121"),
        DeviceProfile(id: 8, name: "Huawei P60 Pro", deviceModel: "HUAWEI MNA-LX9", systemVersion: "HarmonyOS 4.0"),
        DeviceProfile(id: 9, name: "Xiaomi 14", deviceModel: "Xiaomi 2311DRK48G", systemVersion: "Android 14"),
        DeviceProfile(id: 100, name: "Своё устройство", deviceModel: "", systemVersion: "")
    ]
    
    // MARK: - Keys
    
    private enum Keys {
        static let isEnabled = "DeviceSpoof.isEnabled"
        static let selectedProfileId = "DeviceSpoof.selectedProfileId"
        static let customDeviceModel = "DeviceSpoof.customDeviceModel"
        static let customSystemVersion = "DeviceSpoof.customSystemVersion"
    }
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Properties
    
    /// Whether device spoofing is enabled
    public var isEnabled: Bool {
        get { defaults.bool(forKey: Keys.isEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.isEnabled)
            notifyChanged()
        }
    }
    
    /// Selected profile ID (0 = real device, 100 = custom)
    public var selectedProfileId: Int {
        get { defaults.integer(forKey: Keys.selectedProfileId) }
        set {
            defaults.set(newValue, forKey: Keys.selectedProfileId)
            notifyChanged()
        }
    }
    
    /// Custom device model (when profile ID = 100)
    public var customDeviceModel: String {
        get { defaults.string(forKey: Keys.customDeviceModel) ?? "" }
        set {
            defaults.set(newValue, forKey: Keys.customDeviceModel)
            notifyChanged()
        }
    }
    
    /// Custom system version (when profile ID = 100)
    public var customSystemVersion: String {
        get { defaults.string(forKey: Keys.customSystemVersion) ?? "" }
        set {
            defaults.set(newValue, forKey: Keys.customSystemVersion)
            notifyChanged()
        }
    }
    
    // MARK: - Computed
    
    /// Get the currently effective device model
    public var effectiveDeviceModel: String? {
        guard isEnabled else { return nil }
        
        if selectedProfileId == 100 {
            // Custom profile
            let custom = customDeviceModel.trimmingCharacters(in: .whitespacesAndNewlines)
            return custom.isEmpty ? nil : custom
        }
        
        if let profile = Self.profiles.first(where: { $0.id == selectedProfileId }), profile.id != 0 {
            return profile.deviceModel.isEmpty ? nil : profile.deviceModel
        }
        
        return nil
    }
    
    /// Get the currently effective system version
    public var effectiveSystemVersion: String? {
        guard isEnabled else { return nil }
        
        if selectedProfileId == 100 {
            // Custom profile
            let custom = customSystemVersion.trimmingCharacters(in: .whitespacesAndNewlines)
            return custom.isEmpty ? nil : custom
        }
        
        if let profile = Self.profiles.first(where: { $0.id == selectedProfileId }), profile.id != 0 {
            return profile.systemVersion.isEmpty ? nil : profile.systemVersion
        }
        
        return nil
    }
    
    /// Get selected profile
    public var selectedProfile: DeviceProfile? {
        return Self.profiles.first(where: { $0.id == selectedProfileId })
    }
    
    // MARK: - Notification
    
    public static let settingsChangedNotification = Notification.Name("DeviceSpoofSettingsChanged")
    
    private func notifyChanged() {
        NotificationCenter.default.post(name: Self.settingsChangedNotification, object: nil)
    }
    
    // MARK: - Init
    
    private init() {}
}
