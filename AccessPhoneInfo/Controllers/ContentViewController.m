//
//  ContentViewController.m
//  AccessPhoneInfo
//
//  Created by Mon on 2/21/16.
//  Copyright © 2016 Mon. All rights reserved.
//

#import "ContentViewController.h"
#import "AppDelegate+MyAppDelegate.h"

#define PlistArrayInfos(fileName) [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]]
#define notificationCenter [NSNotificationCenter defaultCenter]

@interface ContentViewController ()

@property (nonatomic, strong) NSArray *deviceInfos;

@property (nonatomic, strong) NSArray *deviceOSInfos;
@property (nonatomic, strong) NSArray *deviceOrientationInfos;
@property (nonatomic, strong) NSArray *deviceCarrierInfos;
@property (nonatomic, strong) NSArray *deviceBatteryInfos;
@property (nonatomic, strong) NSArray *deviceNetworkStatusInfos;

@property (nonatomic, strong) NSString *networkStatus;
@property (nonatomic, strong) NSString *batteryLevel;
@property (nonatomic, strong) NSString *batteryState;

@end

@implementation ContentViewController

#pragma mark - System Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Device Infos";
    
    [notificationCenter addObserver:self selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(batteryLevelDidChanged:) name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(batteryStateDidChanged:) name:UIDeviceBatteryStateDidChangeNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [AppDelegate deviceNetworkStatusAsync];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    [notificationCenter removeObserver:self];
}

#pragma mark - Delegate Methods

#pragma mark Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.deviceInfos.count;
}

#pragma mark Cell
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *temp = self.deviceInfos[section];
    return temp.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (section) {
        case 0:
        {
            NSDictionary *dict = self.deviceOSInfos[row];
            cell.textLabel.text = dict[@"key"];
            
            switch (row) {
                case 0:
                    cell.detailTextLabel.text = [AppDelegate isSupportMultitasking];
                    break;
                case 1:
                    cell.detailTextLabel.text = [AppDelegate deviceName];
                    break;
                case 2:
                    cell.detailTextLabel.text = [AppDelegate systemName];
                    break;
                case 3:
                    cell.detailTextLabel.text = [AppDelegate deviceModal];
                    break;
                case 4:
                    cell.detailTextLabel.text = [AppDelegate deviceLocalizedModal];
                    break;
                case 5:
                    cell.detailTextLabel.text = [AppDelegate deviceScreenPreference];
                    break;
                case 6:
                    cell.detailTextLabel.text = [AppDelegate deviceIdentifierForVendor];
                    break;
                    
                default:
                    break;
            }
        }
            break;
        
        case 1:
        {
            NSDictionary *dict = self.deviceOrientationInfos[row];
            cell.textLabel.text = dict[@"key"];
            
            switch (row) {
                case 0:
                    cell.detailTextLabel.text = [AppDelegate deviceOrientation];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:
        {
            NSDictionary *dict = self.deviceCarrierInfos[row];
            cell.textLabel.text = dict[@"key"];
            
            switch (row) {
                case 0:
                    cell.detailTextLabel.text = [AppDelegate deviceCarrier];
                    break;
                case 1:
                    cell.detailTextLabel.text = [AppDelegate deviceNetworkTechnology];
                    break;
                case 2:
                    cell.detailTextLabel.text = [AppDelegate deviceCellularSignal];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 3:
        {
            NSDictionary *dict = self.deviceBatteryInfos[row];
            cell.textLabel.text = dict[@"key"];
            
            switch (row) {
                case 0:
                    cell.detailTextLabel.text = [AppDelegate deviceBatteryLevel];
                    break;
                case 1:
                    cell.detailTextLabel.text = [AppDelegate deviceBatteryState];
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 4:
        {
            NSDictionary *dict = self.deviceNetworkStatusInfos[row];
            cell.textLabel.text = dict[@"key"];
            
            switch (row) {
                case 0:
                    cell.detailTextLabel.text = [AppDelegate deviceNetworkStatusSync];
                    break;
                case 1:
                    cell.detailTextLabel.text = self.networkStatus;
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return @"Device and OS";
        case 1:
            return @"Device Orientation";
        case 2:
            return @"Device Battery State";
        case 3:
            return @"Telephone Carrier Information";
        case 4:
            return @"Telephone Cellular Signal";
        case 5:
            return @"Device Network Status";
            
        default:
            break;
    }
    
    return nil;
}

#pragma mark - Helpers
- (void)networkStatusChanged:(NSNotification *)notif{
    Reachability *reachability = [notif object];
    if ([reachability isKindOfClass:[Reachability class]]) {
        NetworkStatus status = [reachability currentReachabilityStatus];
        
        self.networkStatus = [AppDelegate networkStatus:status];
        [self.tableView reloadData];
    }
}

- (void)orientationChanged:(NSNotification *)notif{
    [UIView animateWithDuration:0.3f animations:^{
        self.tableView.frame = [UIScreen mainScreen].bounds;
    }];
}

- (void)batteryLevelDidChanged:(NSNotification *)notif{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)batteryStateDidChanged:(NSNotification *)notif{
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:3]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Lazy Initialization
- (NSArray *)deviceInfos{
    if (!_deviceInfos) {
        _deviceInfos = @[self.deviceOSInfos, self.deviceOrientationInfos, self.deviceCarrierInfos, self.deviceBatteryInfos, self.deviceNetworkStatusInfos];
    }
    
    return _deviceInfos;
}

- (NSArray *)deviceOSInfos{
    if (!_deviceOSInfos) {
        _deviceOSInfos = PlistArrayInfos(@"DeviceOS");
    }
    
    return _deviceOSInfos;
}

- (NSArray *)deviceOrientationInfos{
    if (!_deviceOrientationInfos) {
        _deviceOrientationInfos = PlistArrayInfos(@"DeviceOrientation");
    }
    
    return _deviceOrientationInfos;
}

- (NSArray *)deviceCarrierInfos{
    if (!_deviceCarrierInfos) {
        _deviceCarrierInfos = PlistArrayInfos(@"Carrier");
    }
    
    return _deviceCarrierInfos;
}

- (NSArray *)deviceBatteryInfos{
    if (!_deviceBatteryInfos) {
        _deviceBatteryInfos = PlistArrayInfos(@"Battery");
    }
    
    return _deviceBatteryInfos;
}

- (NSArray *)deviceNetworkStatusInfos{
    if (!_deviceNetworkStatusInfos) {
        _deviceNetworkStatusInfos = PlistArrayInfos(@"NetworkStatus");
    }
    
    return _deviceNetworkStatusInfos;
}

@end
