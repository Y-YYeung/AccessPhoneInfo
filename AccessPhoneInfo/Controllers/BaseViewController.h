//
//  BaseViewController.h
//  AccessPhoneInfo
//
//  Created by Mon on 2/21/16.
//  Copyright © 2016 Mon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end
