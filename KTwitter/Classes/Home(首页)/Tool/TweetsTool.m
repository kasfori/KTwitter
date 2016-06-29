//
//  TweetsTool.m
//  KTwitter
//
//  Created by K on 16/6/17.
//  Copyright © 2016年 K. All rights reserved.
//

#import "TweetsTool.h"
#import "FMDB.h"

@implementation TweetsTool

static FMDatabase *_db;
+ (void)initialize
{
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"tweets.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    // 2.创表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_tweets (id integer PRIMARY KEY, tweets blob NOT NULL, idstr text NOT NULL);"];
}

+ (NSArray *)tweetsWithParams:(NSDictionary *)params
{
    // 根据请求参数生成对应的查询SQL语句
    NSString *sql = nil;
    if (params[@"since_id"]) {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_tweets WHERE idstr > %@ ORDER BY idstr DESC LIMIT 20;", params[@"since_id"]];
    } else if (params[@"max_id"]) {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_tweets WHERE idstr <= %@ ORDER BY idstr DESC LIMIT 20;", params[@"max_id"]];
    } else {
        sql = @"SELECT * FROM t_tweets ORDER BY idstr DESC LIMIT 20;";
    }
    
    // 执行SQL 返回一个结果集
    FMResultSet *set = [_db executeQuery:sql];
    
    //所有的推文数据
    NSMutableArray *tweets = [NSMutableArray array];
    
    //如果 next 有值
    while (set.next) {
        
        //取出 t_tweets 表里面的 tweets(blob) 字段      代表一条推文的字典
        NSData *tweetsData = [set objectForColumnName:@"tweets"];
        
        // NSData  --> NSDictionary
        NSDictionary *tweet = [NSKeyedUnarchiver unarchiveObjectWithData:tweetsData];
        [tweets addObject:tweet];
    }
    return tweets;
}

+ (void)saveTweets:(NSArray *)tweets
{
    // 要将一个对象存进数据库的blob字段,最好先转为NSData
    // 一个对象要遵守NSCoding协议,实现协议中相应的方法,才能转成NSData
    for (NSDictionary *tweet in tweets) {
        // NSDictionary --> NSData
        NSData *tweetsData = [NSKeyedArchiver archivedDataWithRootObject:tweet];
        [_db executeUpdateWithFormat:@"INSERT INTO t_tweets(tweets, idstr) VALUES (%@, %@);", tweetsData, tweet[@"id_str"]];
    }
}

@end
