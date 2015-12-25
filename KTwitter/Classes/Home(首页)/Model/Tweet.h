//
//  Tweet.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Media.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *createdAt;
@property (nonatomic, assign) NSInteger retweetCount;
@property (nonatomic, assign) NSInteger favoritesCount;
@property (nonatomic, strong) NSArray *atMentions;
@property (nonatomic, strong) Media *media;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) User *retweetedBy;
@property (nonatomic, strong) NSString *id_str;
@property (nonatomic, assign) BOOL favorited;
@property (nonatomic, assign) BOOL retweeted;

- (id) initWithDictionary:(NSDictionary*) dictionary;
+ (NSArray *) tweetsFromArray:(NSArray*) dictionaries;

@end
