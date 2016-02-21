//
//  ViewController.m
//  AccessPhoneInfo
//
//  Created by Mon on 1/18/16.
//  Copyright © 2016 Mon. All rights reserved.
//

#import "Reachability.h"
#import "ViewController.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Reachability *asyncReachability;

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

#pragma mark - System Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self detect];
    
//    [self setupSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [self.asyncReachability stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

#pragma mark - View Helpers
- (void)setupSubviews{
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - helpers
- (void)detect{
    UIDevice *device = [UIDevice currentDevice];
    
#pragma mark Identifying the device and os
    NSLog(@"Identifying the device and os---------");
    NSLog(@"Multitasking supported? %@",@(device.multitaskingSupported));
    NSLog(@"device name: %@",device.name);
    NSLog(@"System name: %@",device.systemName);
    NSLog(@"iOS Device Model: %@",device.model);
    NSLog(@"iOS Device Model localized name: %@",device.localizedModel);
    NSLog(@"Screen Preference: %@",[self screenPreference]);
    NSLog(@"App vendor ID: %@",device.identifierForVendor);
    
#pragma mark Getting the device orientation
    NSLog(@"Getting the device orientation--------");
    NSLog(@"Device Orientation: %@",[self deviceOrientation]);
    
#pragma mark Getting the device battery state
    NSLog(@"Getting the device battery state");
    
    // be sure to set batteryMonitoringEnabled to YES before reading battery's level and state
    device.batteryMonitoringEnabled = YES;
    NSLog(@"Battery level: %@",@(device.batteryLevel));
    NSLog(@"Battery state: %@",[self batteryState]);
    
#pragma mark Access telephone carrier information
    NSLog(@"Access telephone carrier information------");
    
    // be sure to import the library <CoreTelephony/CTTelephonyNetworkInfo.h> and <CoreTelephony/CTCarrier.h>
    CTTelephonyNetworkInfo *teleNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [teleNetworkInfo subscriberCellularProvider];
    NSLog(@"SIM carrier: %@",carrier);
    
    NSString *currentStatus = teleNetworkInfo.currentRadioAccessTechnology;
    NSLog(@"Network technology: %@",[self networkTechnology:currentStatus]);
    
    
#pragma mark Access telephone cellular signal
    NSLog(@"Access telephone cellular signal");
    NSLog(@"Cellular signal: %d",[self accessCellularSignal]);
    
#pragma mark use Reachability to detect network status
    
    // sync
    Reachability *syncReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [syncReachability currentReachabilityStatus];
    NSLog(@"Network status: %@",[self networkStatus:networkStatus]);
    
    // async
    // every time the network status changes, it will post a notification, except the first time when the application starts
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    self.asyncReachability = [Reachability reachabilityForInternetConnection];
    [self.asyncReachability startNotifier];
}

- (NSString *)screenPreference{
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
    }
}

- (NSString *)deviceOrientation{
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
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

- (NSString *)batteryState{
    UIDeviceBatteryState batteryState = [UIDevice currentDevice].batteryState;
    
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

- (int)accessCellularSignal{
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *subviews = [[[app valueForKey:@"statusBar"]     valueForKey:@"foregroundView"] subviews];
    NSString *dataNetworkItemView = nil;
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarSignalStrengthItemView") class]])
        {
            dataNetworkItemView = subview;
            break;
        }
    }
    int signalStrength = [[dataNetworkItemView valueForKey:@"signalStrengthRaw"] intValue];
    return signalStrength;
}

- (NSString *)networkTechnology:(NSString *)status{
    if ([status isEqualToString:CTRadioAccessTechnologyGPRS]) {
        return @"GPRS";
    } else if ([status isEqualToString:CTRadioAccessTechnologyEdge]) {
        return @"Edge";
    } else if ([status isEqualToString:CTRadioAccessTechnologyWCDMA]) {
        return @"WCDMA";
    } else if ([status isEqualToString:CTRadioAccessTechnologyHSDPA]) {
        return @"HSDPA";
    } else if ([status isEqualToString:CTRadioAccessTechnologyHSUPA]) {
        return @"HSUPA";
    } else if ([status isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return @"CDMA1x";
    } else if ([status isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
        return @"CDMAEVDORev0";
    } else if ([status isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
        return @"CDMAEVDORevA";
    } else if ([status isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
        return @"CDMAEVDORevB";
    } else if ([status isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return @"HRPD";
    } else if ([status isEqualToString:CTRadioAccessTechnologyLTE]) {
        return @"LTE";
    } else {
        return nil;
    }
}

- (NSString *)networkStatus:(NetworkStatus)status{
    switch (status) {
        case NotReachable:
            return @"Not reachable";
        case ReachableViaWiFi:
            return @"Wi-Fi";
        case ReachableViaWWAN:
            return @"WWAN";
    }
}

- (void)networkStatusChanged:(NSNotification *)notif{
    Reachability *reachability = [notif object];
    if ([reachability isKindOfClass:[Reachability class]]) {
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        NSLog(@"Async network status: %@",[self networkStatus:status]);
    }
}

#pragma mark - Delegate Methods

@end
