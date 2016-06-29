//
//  TweetCell.m
//  KTwitter
//
//  Created by K on 16/1/6.
//  Copyright © 2016年 K. All rights reserved.
//

#import "TweetCell.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import <UIImageView+WebCache.h>
#import <NSDate+DateTools.h>
#import "Account.h"
#import <AFNetworking.h>
#import "STTwitterAPI.h"
#import "NewTweetViewController.h"

@interface TweetCell ()

@property (nonatomic, strong) Account *account;

@end

@implementation TweetCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self initStyle];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateIconStates];
    self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.frame.size.width;
}

- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    User *user = tweet.user;
    
    if (self.tweet.retweeted_status) {
        tweet = tweet.retweeted_status;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@  转推了",user.name];
        
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweeted_status.favorite_count];
        self.likeCountLabel.hidden = [self.tweet.retweeted_status.favorite_count intValue] == 0;
        
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweeted_status.retweet_count];
        self.retweetCountLabel.hidden = [self.tweet.retweeted_status.retweet_count intValue] == 0;
        
        self.retweetedLabel.hidden = NO;
        self.retweetedImage.hidden = NO;
    } else {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", tweet.favorite_count];
        self.likeCountLabel.hidden = [tweet.favorite_count intValue] == 0;
        
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", tweet.retweet_count];
        self.retweetCountLabel.hidden = [tweet.retweet_count intValue] == 0;
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
    
        [self layoutIfNeeded];
        self.tweet.cellHeight = CGRectGetMaxY(self.buttonsView.frame) + 10;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state

}

+ (instancetype)tweetcellWithTableView:(UITableView *)tableView
{
    static NSString *identifier= @"tweet";
    TweetCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {

        cell=[[[NSBundle mainBundle]loadNibNamed:@"TweetCell" owner:nil options:nil] firstObject];
        //NSLog(@"创建了一个cell");
    }
    return cell;
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
