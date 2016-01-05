//
//  Tweet.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

/** 推文信息内容 */
@property (nonatomic, strong) NSString *text;

/** 推文创建时间 */
@property (nonatomic, strong) NSDate *created_at;

/** 推文转发数 */
@property (nonatomic, assign) NSInteger retweet_count;

/** 推文收藏数 */
@property (nonatomic, assign) NSInteger favorite_count;


@property (nonatomic, strong) NSArray *atMentions;

/**	推文作者的用户信息字段 详细*/
@property (nonatomic, strong) User *user;

/** 转发的推文 如果这个字段为空 代表不是转发的推文 */
@property (nonatomic, strong) User *retweeted_status;

/** 字符串型的推文ID */
@property (nonatomic, strong) NSString *id_str;

/** 收藏推文 */
@property (nonatomic, assign) BOOL favorited;

/** 转发推文 */
@property (nonatomic, assign) BOOL retweeted;

@end
