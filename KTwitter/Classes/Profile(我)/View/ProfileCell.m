//
//  ProfileCell.m
//  KTwitter
//
//  Created by K on 16/6/7.
//  Copyright © 2016年 K. All rights reserved.
//

#import "ProfileCell.h"
#import "Account.h"
#import "STTwitter.h"
#import "User.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "UIView+Extension.h"
@interface ProfileCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic, strong) Account *account;
@end

@implementation ProfileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headerImageView.layer.cornerRadius = 6;
    [self setHeader];
    // Initialization code
}



- (UIImageView *)backgroundImageView {
    return self.bkImageView;
}

- (void)updateHeadPhotoWithTopInset:(CGFloat)inset {
    CGFloat ratio = (inset - 64)/200.0;
    self.bottomConstraint.constant = ratio * 40 + 78;
    //self.widthConstraint.constant = 8 + ratio * 60;
}

- (void)setHeader{
   
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
    NSString *token = [data valueForKey:@"oauth_token"];
    NSString *secret = [data valueForKey:@"oauth_token_secret"];
    NSString *scrname = [data valueForKey:@"screen_name"];
    self.account = [Account instancewithoAuthToken:token secret:secret];
    
    [self.account.twitter getUserInformationFor:scrname successBlock:^(NSDictionary *user) {
        self.user = [User initWithDictionary:user];
        self.name.text = self.user.name;
        self.screenName.text = self.user.screen_name;
        self.info.text = self.user.Description;
        self.tweetCount.text = [NSString stringWithFormat:@"%@",self.user.statuses_count];
        self.followersCount.text = [NSString stringWithFormat:@"%@",self.user.followers_count];
        self.followingCount.text = [NSString stringWithFormat:@"%@",self.user.friends_count];
        
        UIImage *placehoder = [UIImage imageNamed:@"bg_texture"];
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profile_image_url] placeholderImage:placehoder];
        [self.bkImageView sd_setImageWithURL:[NSURL URLWithString:self.user.profile_banner_url] placeholderImage:placehoder];
    } errorBlock:^(NSError *error) {
        NSLog(@"Fetching user info failed: %@", [error userInfo]);
    }];
}

@end
