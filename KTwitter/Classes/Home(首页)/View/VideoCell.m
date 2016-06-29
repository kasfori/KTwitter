//
//  VideoCell.m
//  KTwitter
//
//  Created by K on 16/5/22.
//  Copyright © 2016年 K. All rights reserved.
//

#import "VideoCell.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <NSDate+DateTools.h>
#import "TweetPhoto.h"
#import <MJExtension.h>
#import "ERPlayer.h"
#import "LSPlayerView.h"
#import "Account.h"
#import "STTwitter.h"
@interface VideoCell ()

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
@property (nonatomic, strong) Account *account;
@end

@implementation VideoCell
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
        NSString *token = [data valueForKey:@"oauth_token"];
        NSString *secret = [data valueForKey:@"oauth_token_secret"];
        self.account = [Account instancewithoAuthToken:token secret:secret];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
    [self.photo setUserInteractionEnabled:YES];
    [self.playBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTap:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateIconStates];
    //    viewT.layer.cornerRadius = 10;//设置那个圆角的有多圆
    //    viewT.layer.borderWidth = 10;//设置边框的宽度，当然可以不要
    //    viewT.layer.borderColor = [[UIColor redColor] CGColor];//设置边框的颜色
    //    viewT.layer.masksToBounds = YES;//设为NO去试试。设置YES是保证添加的图片覆盖视图的效果
    self.mediaView.layer.cornerRadius = 6;
    self.mediaView.layer.masksToBounds = YES;
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}



- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    User *user = tweet.user;
    
    if (self.tweet.retweeted_status) {
        tweet = tweet.retweeted_status;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@  转推了",user.name];
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
    
    [self layoutIfNeeded];
    self.tweet.cellHeight = CGRectGetMaxY(self.buttonsView.frame) + 10;
    
    
    
}

- (void)videoTap:(UITapGestureRecognizer *)tap
{

    LSPlayerView* playerView = [LSPlayerView playerView];
    playerView.currentFrame = self.mediaView.frame;
    //必须先设置tempSuperView在设置videoURL
    playerView.tempSuperView = self.superview.superview;
    playerView.videoURL=self.tweet.video_url;

}

- (IBAction)clickReply:(id)sender {
    //    if (self.delegate && [self.delegate respondsToSelector:@selector(pushToNewPage)]) {
    //        [self.delegate pushToNewPage];
    //    }
    if (_ButtnBlock) {
        
        self.ButtnBlock(self.tweet.user.name ,self.tweet.user.screen_name);
    }
    
}

- (IBAction)clickRetweet:(id)sender {
    
    
    
    if (self.tweet.retweeted_status) {
        
        if (self.tweet.retweeted_status.retweeted == 1) {
            self.tweet.retweeted_status.retweeted = NO;
            self.tweet.retweeted_status.retweet_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.retweet_count intValue] - 1];
            
            [self.account.twitter postStatusUnretweetWithID:self.tweet.retweeted_status.ID trimUser:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        } else if(self.tweet.retweeted_status.retweeted == 0){
            
            self.tweet.retweeted_status.retweeted = YES;
            self.tweet.retweeted_status.retweet_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.retweet_count intValue] + 1];
            
            [self.account.twitter postStatusRetweetWithID:self.tweet.retweeted_status.ID successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            
            [self setTweet:self.tweet];
            [self updateIconStates];
        }
    } else {
        
        if (self.tweet.retweeted == 1) {
            
            self.tweet.retweeted = NO;
            self.tweet.retweet_count = [NSNumber numberWithInt:[self.tweet.retweet_count intValue] - 1];
            [self.account.twitter postStatusUnretweetWithID:self.tweet.ID trimUser:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        } else if(self.tweet.retweeted == 0){
            
            self.tweet.retweeted = YES;
            self.tweet.retweet_count = [NSNumber numberWithInt:[self.tweet.retweet_count intValue] + 1];
            
            [self.account.twitter postStatusRetweetWithID:self.tweet.ID successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        }
        
        
    }
}


- (IBAction)clickFavorite:(id)sender {
    
    if (self.tweet.retweeted_status) {
        
        if (self.tweet.retweeted_status.favorited == 1) {
            
            self.tweet.retweeted_status.favorited = NO;
            self.tweet.retweeted_status.favorite_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.favorite_count intValue] - 1];
            [self.account.twitter postFavoriteDestroyWithStatusID:self.tweet.retweeted_status.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        } else if(self.tweet.retweeted_status.favorited == 0){
            
            self.tweet.retweeted_status.favorited = YES;
            self.tweet.retweeted_status.favorite_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.favorite_count intValue] + 1];
            [self.account.twitter postFavoriteCreateWithStatusID:self.tweet.retweeted_status.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
        }
        
    } else {
        
        if (self.tweet.favorited == 1) {
            
            self.tweet.favorited = NO;
            self.tweet.favorite_count = [NSNumber numberWithInt:[self.tweet.favorite_count intValue] - 1];
            [self.account.twitter postFavoriteDestroyWithStatusID:self.tweet.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        } else if(self.tweet.favorited == 0){
            
            self.tweet.favorited = YES;
            self.tweet.favorite_count = [NSNumber numberWithInt:[self.tweet.favorite_count intValue] + 1];
            [self.account.twitter postFavoriteCreateWithStatusID:self.tweet.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        }
    }
    
}

-(void) updateIconStates {
    
    
    if (self.tweet.retweeted_status) {
        
        [self.likeButton setImage:[UIImage imageNamed:self.tweet.retweeted_status.favorited ? @"icn_tweet_action_favorite_on" : @"icn_tweet_action_favorite_off"] forState:UIControlStateNormal];
        
        [self.retweetButton setImage:[UIImage imageNamed:self.tweet.retweeted_status.retweeted ? @"icn_tweet_action_retweet_on" : @"icn_tweet_action_retweet_off"] forState:UIControlStateNormal];
        
        
    } else {
        
        [self.likeButton setImage:[UIImage imageNamed:self.tweet.favorited ? @"icn_tweet_action_favorite_on" : @"icn_tweet_action_favorite_off"] forState:UIControlStateNormal];
        
        [self.retweetButton setImage:[UIImage imageNamed:self.tweet.retweeted ? @"icn_tweet_action_retweet_on" : @"icn_tweet_action_retweet_off"] forState:UIControlStateNormal];
    }
    
}
+ (instancetype)videoTweetcellWithTableView:(UITableView *)tableView
{
    static NSString *identifier= @"videoTweet";
    VideoCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        
        cell=[[[NSBundle mainBundle]loadNibNamed:@"VideoCell" owner:nil options:nil] firstObject];
    }
    return cell;
}

#pragma mark - Initializers



- (void)initStyle
{
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
    [self.nameLabel sizeToFit];
    self.screenNameLabel.preferredMaxLayoutWidth = self.screenNameLabel.frame.size.width;
    [self.screenNameLabel sizeToFit];
    self.tweetTextLabel.preferredMaxLayoutWidth = self.tweetTextLabel.frame.size.width;
    self.tweetTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tweetTextLabel.numberOfLines = 0;
    [self.tweetTextLabel sizeToFit];
}

@end
