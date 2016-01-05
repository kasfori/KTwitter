
//
//  User.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "User.h"
#import <MJExtension.h>

@implementation User

// 将字典里的 description属性 转成对应模型的 Description属性

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"Description" : @"description"};
}

@end

