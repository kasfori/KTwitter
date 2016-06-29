//
//  Tweet.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "TweetPhoto.h"

@interface Tweet : NSObject

/** 推文信息内容 */
@property (nonatomic, strong) NSString *text;

/** 推文创建时间 */
@property (nonatomic, strong) NSString *created_at;

/** 推文转发数 */
@property (nonatomic, assign) NSNumber *retweet_count;

/** 推文收藏数 */
@property (nonatomic, assign) NSNumber *favorite_count;

/** 推文的媒体 如果没有 字段为空*/

@property (nonatomic, strong) NSString *media_url0;

@property (nonatomic, strong) NSString *media_url1;

@property (nonatomic, strong) NSString *media_url2;

@property (nonatomic, strong) NSString *media_url3;

@property (nonatomic, strong) NSString *video_url;

/**	推文用户信息字段 详细*/
@property (nonatomic, strong) User *user;

@property (nonatomic, strong) NSString *ID;

/** 推文ID */
@property (nonatomic, strong) NSString *id_str;

/** 收藏 */
@property (nonatomic, assign) BOOL favorited;

/** 转发 */
@property (nonatomic, assign) BOOL retweeted;


/** 转发的推文 如果这个字段为空 代表不是转发的推文 */
@property (nonatomic, strong) Tweet *retweeted_status;

@property (nonatomic, assign) CGFloat cellHeight;

@end
