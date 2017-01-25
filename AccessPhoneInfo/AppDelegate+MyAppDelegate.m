//
//  AppDelegate+MyAppDelegate.m
//  AccessPhoneInfo
//
//  Created by Mon on 2/20/16.
//  Copyright © 2016 Mon. All rights reserved.
//

#import "Reachability.h"
#import "AppDelegate+MyAppDelegate.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define ThisDevice [UIDevice currentDevice]

static Reachability *asyncReachability;

@implementation AppDelegate (MyAppDelegate)

#pragma mark - Identifying the device and os
+ (NSString *)isSupportMultitasking{
    BOOL supportMultitasking = ThisDevice.multitaskingSupported;
    
    if (supportMultitasking) {
        return @"Support";
    } else {
        return @"Not Support";
    }
}

+ (NSString *)deviceName{
    return ThisDevice.name;
}

+ (NSString *)systemName{
    return ThisDevice.systemName;
}

+ (NSString *)deviceModal{
    return ThisDevice.model;
}

+ (NSString *)deviceLocalizedModal{
    return ThisDevice.localizedModel;
}

+ (NSString *)deviceIdentifierForVendor{
    return ThisDevice.identifierForVendor.UUIDString;
}

+ (NSString *)deviceScreenPreference{
    return [self screenPreference];
}

+ (NSString *)screenPreference{
    UIUserInterfaceIdiom idiom = [UIDevice currentDevice].userInterfaceIdiom;
    switch (idiom) {
        case UIUserInterfaceIdiomUnspecified:
            return @"Unspecified";
        case UIUserInterfaceIdiomTV:
            return @"Apple TV";
        case UIUserInterfaceIdiomPad:
            return @"iPad";
        case UIUserInterfaceIdiomPhone:
            return @"iPhone";
            
        default:
            return nil;
    }
}

+ (NSString *)deviceBatteryLevel{
    // be sure to set batteryMonitoringEnabled to YES before reading battery's level and state
    ThisDevice.batteryMonitoringEnabled = YES;
    NSString *batteryLevel = [NSString stringWithFormat:@"%.2f",ThisDevice.batteryLevel];
    return batteryLevel;
}

+ (NSString *)deviceBatteryState{
    UIDeviceBatteryState batteryState = ThisDevice.batteryState;
    
    switch (batteryState) {
        case UIDeviceBatteryStateUnknown:
            return @"Battery State Unknown";
        case UIDeviceBatteryStateUnplugged:
            return @"Battery State Not Charging";
        case UIDeviceBatteryStateCharging:
            return @"Battery State Charging";
        case UIDeviceBatteryStateFull:
            return @"Battery State Full";
    }
}

#pragma mark - Access device orientation
+ (NSString *)deviceOrientation{
    UIDeviceOrientation orientation = ThisDevice.orientation;
    
    switch (orientation) {
        case UIDeviceOrientationUnknown:
            return @"Unknown";
        case UIDeviceOrientationPortrait:
            return @"Portrait";
        case UIDeviceOrientationPortraitUpsideDown:
            return @"Portrait but upside down";
        case UIDeviceOrientationLandscapeLeft:
            return @"Landscape but home button on the right";
        case UIDeviceOrientationLandscapeRight:
            return @"Landscape but home button on the left";
        case UIDeviceOrientationFaceUp:
            return @"Screen faces upwards";
        case UIDeviceOrientationFaceDown:
            return @"Screen faces downwards";
    }
}

#pragma mark - Access telephone carrier information
+ (NSString *)deviceCarrier{
    // be sure to import the library <CoreTelephony/CTTelephonyNetworkInfo.h> and <CoreTelephony/CTCarrier.h>
    CTTelephonyNetworkInfo *teleNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [teleNetworkInfo subscriberCellularProvider];
    return carrier.carrierName;
}

+ (NSString *)deviceNetworkTechnology{
    // be sure to import the library <CoreTelephony/CTTelephonyNetworkInfo.h> and <CoreTelephony/CTCarrier.h>
    CTTelephonyNetworkInfo *teleNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString *currentStatus = teleNetworkInfo.currentRadioAccessTechnology;
    
    if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return @"GPRS";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
        return @"Edge";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return @"WCDMA";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return @"HSDPA";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return @"HSUPA";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"CDMA1x";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return @"CDMAEVDORev0";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return @"CDMAEVDORevA";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return @"CDMAEVDORevB";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"HRPD";
    } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"LTE";
    } else {
        return nil;
    }
}

#pragma mark - Access telephone cellular signal
+ (NSString *)deviceCellularSignal{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    
    int signalStrength = [[dataNetworkItemView valueForKey:@"signalStrengthRaw"] intValue];
    return [NSString stringWithFormat:@"%d", signalStrength];
}

#pragma mark - Access network status using Reachability
+ (NSString *)deviceNetworkStatusSync{
    // sync
    Reachability *syncReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [syncReachability currentReachabilityStatus];
    
    return [self networkStatus:networkStatus];
}

+ (void)deviceNetworkStatusAsync{
    // async
    // every time the network status changes, it will post a notification, except the first time when the application starts
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    asyncReachability = [Reachability reachabilityForInternetConnection];
    [asyncReachability startNotifier];
}

+ (NSString *)networkStatus:(NetworkStatus)status{
    switch (status) {
        case NotReachable:
            return @"Not reachable";
        case ReachableViaWiFi:
            return @"Wi-Fi";
        case ReachableViaWWAN:
            return @"WWAN";
    }
}

@end
