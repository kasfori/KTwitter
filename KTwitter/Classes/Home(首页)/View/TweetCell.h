//
//  TweetCell.h
//  KTwitter
//
//  Created by K on 16/1/6.
//  Copyright © 2016年 K. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Tweet;

typedef void (^ButtnBlock)(NSString *name , NSString *scrName);

@interface TweetCell : UITableViewCell

@property (nonatomic, strong) Tweet *tweet;

+ (instancetype)tweetcellWithTableView:(UITableView *)tableView;


@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

@property (nonatomic, copy) void (^ButtnBlock)(NSString *name , NSString *scrName);

@end
