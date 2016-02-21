//
//  AppDelegate+MyAppDelegate.h
//  AccessPhoneInfo
//
//  Created by Mon on 2/20/16.
//  Copyright © 2016 Mon. All rights reserved.
//

#import "Reachability.h"
#import "AppDelegate.h"

@interface AppDelegate (MyAppDelegate)

+ (NSString *)isSupportMultitasking;
+ (NSString *)deviceName;
+ (NSString *)systemName;
+ (NSString *)deviceModal;
+ (NSString *)deviceLocalizedModal;
+ (NSString *)deviceIdentifierForVendor;
+ (NSString *)deviceScreenPreference;

+ (NSString *)deviceBatteryLevel;
+ (NSString *)deviceBatteryState;

+ (NSString *)deviceOrientation;

+ (NSString *)deviceCarrier;
+ (NSString *)deviceNetworkTechnology;
+ (NSString *)deviceCellularSignal;

+ (NSString *)deviceNetworkStatusSync;
+ (void)deviceNetworkStatusAsync;

+ (NSString *)networkStatus:(NetworkStatus)status;

@end
