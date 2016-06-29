//
//  TweetsTool.h
//  KTwitter
//
//  Created by K on 16/6/17.
//  Copyright © 2016年 K. All rights reserved.
//  推文工具类:用来处理推文数据的缓存

#import <Foundation/Foundation.h>

@interface TweetsTool : NSObject

/**
 *  根据请求参数去沙盒中加载缓存的推文数据
 *
 *  @param params 请求参数
 */
+ (NSArray *)tweetsWithParams:(NSDictionary *)params;

/**
 *  存储推文数据到沙盒中
 *
 *  @param statuses 需要存储的微博数据
 */
+ (void)saveTweets:(NSArray *)tweets;

@end
