//
//  Account.h
//  KTwitter
//
//  Created by K on 15/12/28.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>
@class STTwitterAPI, User;

@interface Account : NSObject

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, strong) User *user;

///**  screenName  */
//@property (nonatomic, copy) NSString *screen_name;
//
///**  userID  */
//@property (nonatomic, copy) NSString *user_id;
//
///**  AccessToken  */
//@property (nonatomic, copy) NSString *access_token;
//
//@property (nonatomic, copy) NSString *verifier;
//
///**  AccessTokenSecret  */
//@property (nonatomic, copy) NSString *accessToken_secret;


//+ (instancetype)accountWithDict:(NSDictionary *)dict;

-(void)getUserInfo:(NSString *)userID;

+ (Account *)instancewithoAuthToken: (NSString*)token secret:(NSString*)secret;

-(void)logout;

@end
