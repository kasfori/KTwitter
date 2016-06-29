//
//  VideoDetailView.m
//  KTwitter
//
//  Created by K on 16/5/22.
//  Copyright © 2016年 K. All rights reserved.
//

#import "VideoDetailView.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import "TweetPhoto.h"
#import "ERPlayer.h"
#import "LSPlayerView.h"
#import "WMPlayer.h"

@interface VideoDetailView ()
{
    WMPlayer *wmPlayer;
}

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
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end

@implementation VideoDetailView

//- (void)awakeFromNib {
//    // Initialization code
//    self.mediaView.layer.cornerRadius = 6;
//    self.mediaView.layer.masksToBounds = YES;
//    [self.photo setUserInteractionEnabled:YES];
//    [self.playBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTap:)]];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.mediaView.layer.cornerRadius = 6;
    self.mediaView.layer.masksToBounds = YES;
    [self.photo setUserInteractionEnabled:YES];
    [self.playBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTap:)]];

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



- (void)videoTap:(UITapGestureRecognizer *)tap
{
    
    
    wmPlayer = [[WMPlayer alloc]initWithFrame:self.mediaView.bounds videoURLStr:self.tweet.video_url];
    [self.mediaView addSubview:wmPlayer];
    [wmPlayer play];
    
    //    ERPlayer *player = [ERPlayer new];
    //    player.frame = self.window.bounds;
    //    [player setViedoUrl:self.tweet.video_url];
    //    [self.window addSubview:player];
    
    
//    LSPlayerView* playerView = [LSPlayerView playerView];
//    playerView.currentFrame = self.mediaView.frame;
//    //必须先设置tempSuperView在设置videoURL
//    playerView.tempSuperView = self.superclass;
//    playerView.videoURL=self.tweet.video_url;
    
    
}

@end
