//
//  HomeViewController.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STTwitter.h>

@interface HomeViewController : UITableViewController <UITableViewDataSource, UIActionSheetDelegate, STTwitterRequestProtocol>

@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, strong) STTwitterAPI *twitter;


- (void)loadstatuses;

@end
