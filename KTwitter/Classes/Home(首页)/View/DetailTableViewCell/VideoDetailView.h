//
//  VideoDetailView.h
//  KTwitter
//
//  Created by K on 16/5/22.
//  Copyright © 2016年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Tweet;
@interface VideoDetailView : UIViewController

@property (nonatomic, weak) Tweet *tweet;

- (void)loadTweetViewWithTweet:(Tweet *) tweet;

@end
