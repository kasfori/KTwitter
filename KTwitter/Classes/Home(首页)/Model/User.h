//
//  User.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screen_name;
@property (nonatomic, strong) NSString *profile_image_url;
@property (nonatomic, strong) NSString *profile_banner_url;
@property (nonatomic, strong) NSString *Description;
@property (nonatomic, assign) NSNumber *friends_count;
@property (nonatomic, assign) NSNumber *followers_count;
@property (nonatomic, assign) NSNumber *statuses_count;


+ (User *)initWithDictionary:(NSDictionary *)dictionary;

@end
