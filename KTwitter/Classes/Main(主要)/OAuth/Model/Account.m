//
//  Account.m
//  KTwitter
//
//  Created by K on 15/12/28.
//  Copyright © 2015年 K. All rights reserved.
//

#import "Account.h"
#import "STTwitterAPI.h"
#import "User.h"

////官方key
//#define TWITTER_CONSUMER_KEY @"IQKbtAYlXLripLGPWd0HUA"
//#define TWITTER_CONSUMER_SECRET @"GgDYlkSvaPxGxC4X8liwpUoqKwwr3lCADbz8A7ADU"

#define TWITTER_CONSUMER_KEY @"LtDZT4MSUZalnz9CbGZSs2tCH"
#define TWITTER_CONSUMER_SECRET @"IjAp2rOMnVCO4zRgSYDmanTybDvPFAEMKsbzHsSdpXwKVk2CA3"

@implementation Account

+ (Account *)instancewithoAuthToken: (NSString*)token secret:(NSString*)secret {
    
    static dispatch_once_t once;
    static Account *instance;
    
    dispatch_once(&once, ^{
        instance = [[Account alloc] init];
        if(token != nil && secret != nil) {
            instance.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET oauthToken:token oauthTokenSecret:secret];
        } else {
            instance.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY consumerSecret:TWITTER_CONSUMER_SECRET];
        }
    });
    
    return instance;
}

-(void)logout {
    _twitter = nil;
    
    //Shall we remove access_tokens ?
}

-(void)getUserInfo:(NSString *)userID {
    
    [_twitter getUserInformationFor:userID successBlock:^(NSDictionary *user) {
        self.user = [User initWithDictionary:user];
        //NSLog(@"Active user: %@", user);
        
    } errorBlock:^(NSError *error) {
        //NSLog(@"Fetching user info failed: %@", [error userInfo]);
        
    }];
}

//+ (instancetype)accountWithDict:(NSDictionary *)dict
//{
//    Account *account = [[self alloc] init];
//    account.screen_name = dict[@"screen_name"];
//    account.user_id = dict[@"user_id"];
//    account.access_token = dict[@"oauth_token"];
//    account.accessToken_secret = dict[@"oauth_token_secret"];
//    account.verifier = dict[@"oauth_verifier"];
//    return account;
//}
//
///**
// *  当一个对象要归档进沙盒中时，就会调用这个方法
// *  目的：在这个方法中说明这个对象的哪些属性要存进沙盒
// */
//- (void)encodeWithCoder:(NSCoder *)encoder
//{
//    [encoder encodeObject:self.screen_name forKey:@"screen_name"];
//    [encoder encodeObject:self.user_id forKey:@"user_id"];
//    [encoder encodeObject:self.access_token forKey:@"oauth_token"];
//    [encoder encodeObject:self.accessToken_secret forKey:@"oauth_token_secret"];
//    [encoder encodeObject:self.verifier forKey:@"oauth_verifier"];
//}
//
///**
// *  当从沙盒中解档一个对象时（从沙盒中加载一个对象时），就会调用这个方法
// *  目的：在这个方法中说明沙盒中的属性该怎么解析（需要取出哪些属性）
// */
//- (id)initWithCoder:(NSCoder *)decoder
//{
//    if (self = [super init]) {
//        self.screen_name = [decoder decodeObjectForKey:@"screen_name"];
//        self.user_id = [decoder decodeObjectForKey:@"user_id"];
//        self.access_token = [decoder decodeObjectForKey:@"oauth_token"];
//        self.accessToken_secret = [decoder decodeObjectForKey:@"oauth_token_secret"];
//        self.verifier = [decoder decodeObjectForKey:@"oauth_verifier"];
//    }
//    return self;
//}
@end
