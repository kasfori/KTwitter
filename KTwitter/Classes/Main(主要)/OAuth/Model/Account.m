//
//  Account.m
//  KTwitter
//
//  Created by K on 15/12/28.
//  Copyright © 2015年 K. All rights reserved.
//

#import "Account.h"

@implementation Account

+ (instancetype)accountWithDict:(NSDictionary *)dict
{
    Account *account = [[self alloc] init];
    account.screen_name = dict[@"screen_name"];
    account.user_id = dict[@"user_id"];
    account.access_token = dict[@"oauth_token"];
    account.accessToken_secret = dict[@"oauth_token_secret"];
    return account;
}

/**
 *  当一个对象要归档进沙盒中时，就会调用这个方法
 *  目的：在这个方法中说明这个对象的哪些属性要存进沙盒
 */
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.screen_name forKey:@"screen_name"];
    [encoder encodeObject:self.user_id forKey:@"user_id"];
    [encoder encodeObject:self.access_token forKey:@"oauth_token"];
    [encoder encodeObject:self.accessToken_secret forKey:@"oauth_token_secret"];
}

/**
 *  当从沙盒中解档一个对象时（从沙盒中加载一个对象时），就会调用这个方法
 *  目的：在这个方法中说明沙盒中的属性该怎么解析（需要取出哪些属性）
 */
- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.screen_name = [decoder decodeObjectForKey:@"screen_name"];
        self.user_id = [decoder decodeObjectForKey:@"user_id"];
        self.access_token = [decoder decodeObjectForKey:@"oauth_token"];
        self.accessToken_secret = [decoder decodeObjectForKey:@"oauth_token_secret"];
    }
    return self;
}

@end
