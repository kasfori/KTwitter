//
//  VideoCell.h
//  KTwitter
//
//  Created by K on 16/5/22.
//  Copyright © 2016年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"
typedef void (^ButtnBlock)(NSString *name , NSString *scrName);
@interface VideoCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;
@property (nonatomic, copy) void (^ButtnBlock)(NSString *name , NSString *scrName);
+ (instancetype)videoTweetcellWithTableView:(UITableView *)tableView;
@end
