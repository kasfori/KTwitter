//
//  ProfileCell.h
//  KTwitter
//
//  Created by K on 16/6/7.
//  Copyright © 2016年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARSegmentPageControllerHeaderProtocol.h"
@class User;

@interface ProfileCell : UIView<ARSegmentPageControllerHeaderProtocol>

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *info;
@property (weak, nonatomic) IBOutlet UILabel *tweetCount;
@property (weak, nonatomic) IBOutlet UILabel *followingCount;
@property (weak, nonatomic) IBOutlet UILabel *followersCount;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bkImageView;

- (void)updateHeadPhotoWithTopInset:(CGFloat)inset;
@property (strong, nonatomic) User *user;

@end
