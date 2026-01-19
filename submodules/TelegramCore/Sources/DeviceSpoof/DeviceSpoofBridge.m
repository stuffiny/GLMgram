#import "DeviceSpoofBridge.h"

// Access to UserDefaults to get spoofing settings
// This mirrors DeviceSpoofManager logic but in pure Objective-C
// to avoid Swift/ObjC bridging complexities in MtProtoKit

static NSString *const kDeviceSpoofIsEnabled = @"DeviceSpoof.isEnabled";
static NSString *const kDeviceSpoofSelectedProfileId =
    @"DeviceSpoof.selectedProfileId";
static NSString *const kDeviceSpoofCustomDeviceModel =
    @"DeviceSpoof.customDeviceModel";
static NSString *const kDeviceSpoofCustomSystemVersion =
    @"DeviceSpoof.customSystemVersion";

@implementation DeviceSpoofBridge

+ (BOOL)isEnabled {
  return
      [[NSUserDefaults standardUserDefaults] boolForKey:kDeviceSpoofIsEnabled];
}

+ (NSString *)spoofedDeviceModel {
  if (![self isEnabled]) {
    return nil;
  }

  NSInteger profileId = [[NSUserDefaults standardUserDefaults]
      integerForKey:kDeviceSpoofSelectedProfileId];

  // Profile ID 0 = real device
  if (profileId == 0) {
    return nil;
  }

  // Profile ID 100 = custom
  if (profileId == 100) {
    NSString *custom = [[NSUserDefaults standardUserDefaults]
        stringForKey:kDeviceSpoofCustomDeviceModel];
    if (custom.length > 0) {
      return custom;
    }
    return nil;
  }

  // Preset profiles
  NSDictionary<NSNumber *, NSString *> *profiles = @{
    @1 : @"iPhone 14 Pro",
    @2 : @"iPhone 15 Pro Max",
    @3 : @"Samsung SM-S918B",
    @4 : @"Google Pixel 8 Pro",
    @5 : @"PC 64bit",
    @6 : @"MacBook Pro",
    @7 : @"Web",
    @8 : @"HUAWEI MNA-LX9",
    @9 : @"Xiaomi 2311DRK48G"
  };

  return profiles[@(profileId)];
}

+ (NSString *)spoofedSystemVersion {
  if (![self isEnabled]) {
    return nil;
  }

  NSInteger profileId = [[NSUserDefaults standardUserDefaults]
      integerForKey:kDeviceSpoofSelectedProfileId];

  // Profile ID 0 = real device
  if (profileId == 0) {
    return nil;
  }

  // Profile ID 100 = custom
  if (profileId == 100) {
    NSString *custom = [[NSUserDefaults standardUserDefaults]
        stringForKey:kDeviceSpoofCustomSystemVersion];
    if (custom.length > 0) {
      return custom;
    }
    return nil;
  }

  // Preset profiles
  NSDictionary<NSNumber *, NSString *> *versions = @{
    @1 : @"iOS 17.2",
    @2 : @"iOS 17.4",
    @3 : @"Android 14",
    @4 : @"Android 14",
    @5 : @"Windows 11",
    @6 : @"macOS 14.3",
    @7 : @"Chrome 121",
    @8 : @"HarmonyOS 4.0",
    @9 : @"Android 14"
  };

  return versions[@(profileId)];
}

@end
