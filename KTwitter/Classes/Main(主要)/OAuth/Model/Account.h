//
//  Account.h
//  KTwitter
//
//  Created by K on 15/12/28.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject <NSCoding>


/**  screenName  */
@property (nonatomic, copy) NSString *screen_name;

/**  userID  */
@property (nonatomic, copy) NSString *user_id;

/**  AccessToken  */
@property (nonatomic, copy) NSString *access_token;

/**  AccessTokenSecret  */
@property (nonatomic, copy) NSString *accessToken_secret;

+ (instancetype)accountWithDict:(NSDictionary *)dict;

@end
