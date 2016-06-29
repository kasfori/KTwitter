//
//  MediaDetailView.m
//  KTwitter
//
//  Created by K on 16/5/20.
//  Copyright © 2016年 K. All rights reserved.
//

#import "MediaDetailView.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "TweetPhoto.h"
#import <MJPhoto.h>
#import <MJPhotoBrowser.h>


@interface MediaDetailView ()

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
@property (weak, nonatomic) IBOutlet UIImageView *photo;

@end

@implementation MediaDetailView

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mediaView.layer.cornerRadius = 6;
    self.mediaView.layer.masksToBounds = YES;
    [self.photo setUserInteractionEnabled:YES];
    [self.photo addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoTap:)]];
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
    
    self.photo.contentMode = UIViewContentModeScaleAspectFill;
    // 超出边框的内容都剪掉
    self.photo.clipsToBounds = YES;
    [self.photo sd_setImageWithURL:[NSURL URLWithString:tweet.media_url0] placeholderImage:[UIImage imageNamed:@"timeline_image_placeholder"]];
    
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
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.tweet.media_url0, nil];
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:array.count];
    
    for (int i = 0; i < array.count; i--) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        
        photo.url = [NSURL URLWithString:self.tweet.media_url0];
        
        //NSLog(@"%@66666",photo.url);
        
        // 原图父控件
        photo.srcImageView = self.mediaView.subviews[i];
        
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
    
    //NSLog(@"%@",array);
}


@end
