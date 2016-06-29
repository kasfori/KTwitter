
//
//  User.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "User.h"

@interface User()

@property (nonatomic, strong) NSDictionary *dictionary;


@end

@implementation User

+ (User *)initWithDictionary:(NSDictionary *)dictionary
{
        User *user = [[User alloc] init];
    
        user.name = dictionary[@"name"];
        user.screen_name = dictionary[@"screen_name"];
        user.profile_banner_url = dictionary[@"profile_banner_url"];
        user.profile_image_url = dictionary[@"profile_image_url"];
        user.Description = dictionary[@"description"];
        user.friends_count = dictionary[@"friends_count"];
        user.followers_count = dictionary[@"followers_count"];
        user.statuses_count = dictionary[@"statuses_count"];
    
    return user;
}

@end

