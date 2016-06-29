//
//  MediaCell.h
//  KTwitter
//
//  Created by K on 16/1/15.
//  Copyright © 2016年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

typedef void (^ButtnBlock)(NSString *name , NSString *scrName);

@interface MediaCell1 : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

+ (instancetype)mediaTweetcell1WithTableView:(UITableView *)tableView;

@property (nonatomic, copy) void (^ButtnBlock)(NSString *name , NSString *scrName);

@end
