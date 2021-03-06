//
//  MediaDetailView3.m
//  KTwitter
//
//  Created by K on 16/5/21.
//  Copyright © 2016年 K. All rights reserved.
//

#import "MediaDetailView3.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "TweetPhoto.h"
#import <MJPhoto.h>
#import <MJPhotoBrowser.h>


@interface MediaDetailView3 ()
@property (weak, nonatomic) IBOutlet UIImageView *retweetedImage;
@property (weak, nonatomic) IBOutlet UILabel *retweetedLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UIView *mediaView;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIImageView *photo1;
@property (weak, nonatomic) IBOutlet UIImageView *photo2;
@property (weak, nonatomic) IBOutlet UIImageView *photo3;
@property (weak, nonatomic) IBOutlet UIImageView *photo4;
@end

@implementation MediaDetailView3

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mediaView.layer.cornerRadius = 6;
    self.mediaView.layer.masksToBounds = YES;
    [self.photo1 setUserInteractionEnabled:YES];
    [self.photo1 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
    [self.photo2 setUserInteractionEnabled:YES];
    [self.photo2 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
    [self.photo3 setUserInteractionEnabled:YES];
    [self.photo3 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
    [self.photo4 setUserInteractionEnabled:YES];
    [self.photo4 addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
    [self loadTweetViewWithTweet:self.tweet];
}

- (void)loadTweetViewWithTweet:(Tweet *)tweet
{
    if (self.tweet.retweeted_status) {
        tweet = tweet.retweeted_status;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@  转推了",self.tweet.user.name];
        self.retweetedLabel.hidden = NO;
        self.retweetedImage.hidden = NO;
    } else {
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
    }
    UIImage *placehoder = [UIImage imageNamed:@"bg_texture"];
    
    
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:tweet.user.profile_image_url] placeholderImage:placehoder];
    self.profileImage.layer.cornerRadius = 5;
    self.nameLabel.text = tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@",tweet.user.screen_name];
    self.tweetTextLabel.text = tweet.text;
    self.createdAtLabel.text = tweet.created_at;
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", tweet.retweet_count];
    self.retweetCountLabel.hidden = [tweet.retweet_count intValue] == 0;
    self.likeCountLabel.text = [NSString stringWithFormat:@"%@", tweet.favorite_count];
    self.likeCountLabel.hidden = [tweet.favorite_count intValue] == 0;
    
    self.photo1.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边框的内容都剪掉
    self.photo1.clipsToBounds = YES;
    [self.photo1 sd_setImageWithURL:[NSURL URLWithString:tweet.media_url0] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    self.photo2.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边框的内容都剪掉
    self.photo2.clipsToBounds = YES;
    [self.photo2 sd_setImageWithURL:[NSURL URLWithString:tweet.media_url1] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    self.photo3.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边框的内容都剪掉
    self.photo3.clipsToBounds = YES;
    [self.photo3 sd_setImageWithURL:[NSURL URLWithString:tweet.media_url2] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    self.photo4.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边框的内容都剪掉
    self.photo4.clipsToBounds = YES;
    [self.photo4 sd_setImageWithURL:[NSURL URLWithString:tweet.media_url3] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
    if (self.tweet.retweeted) {
        self.retweetButton.imageView.image = [UIImage imageNamed:@"icn_tweet_action_retweet_on"];
    } else {
        self.retweetButton.imageView.image = [UIImage imageNamed:@"icn_tweet_action_retweet_off"];
    }
    
    if (self.tweet.favorited) {
        self.likeButton.imageView.image = [UIImage imageNamed:@"icn_tweet_action_favorite_on"];
    } else {
        self.likeButton.imageView.image = [UIImage imageNamed:@"icn_tweet_action_favorite_off"];
    }
}

- (void)photoTap:(UITapGestureRecognizer *)tap
{
    NSArray *array = [[NSMutableArray alloc] initWithObjects:self.tweet.media_url0,self.tweet.media_url1,self.tweet.media_url2,self.tweet.media_url3, nil];
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:array.count];
    
    for (int i = 0; i < array.count; i--) {
        MJPhoto *photo1 = [[MJPhoto alloc] init];
        photo1.url = [NSURL URLWithString:self.tweet.media_url0];
        
        MJPhoto *photo2 = [[MJPhoto alloc] init];
        photo2.url = [NSURL URLWithString:self.tweet.media_url1];
        
        MJPhoto *photo3 = [[MJPhoto alloc] init];
        photo3.url = [NSURL URLWithString:self.tweet.media_url2];
        
        MJPhoto *photo4 = [[MJPhoto alloc] init];
        photo4.url = [NSURL URLWithString:self.tweet.media_url3];
        
        //        NSLog(@"%@66666",photo1.url);
        //        NSLog(@"%@66666",photo2.url);
        //        NSLog(@"%@66666",photo3.url);
        //        NSLog(@"%@66666",photo3.url);
        
        // 原图父控件
        photo1.srcImageView = self.mediaView.subviews[i];
        photo2.srcImageView = self.mediaView.subviews[i];
        photo3.srcImageView = self.mediaView.subviews[i];
        photo4.srcImageView = self.mediaView.subviews[i];
        
        [photos addObject:photo1];
        [photos addObject:photo2];
        [photos addObject:photo3];
        [photos addObject:photo4];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    
    //NSLog(@"%@",array);
}

@end
