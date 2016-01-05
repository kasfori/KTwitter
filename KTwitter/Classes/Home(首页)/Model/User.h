//
//  User.h
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

/** 昵称 */
@property (nonatomic, strong) NSString *name;

/** 用户名 @XXX */
@property (nonatomic, strong) NSString *screen_name;

/** 头像 48 * 48 */
@property (nonatomic, strong) NSString *profile_image_url;

/** 背景图片 */
@property (nonatomic, strong) NSString *profile_banner_url;

/** 个人信息描述 */
@property (nonatomic, strong) NSString  *Description;

/** 我正在关注的人--数量 */
@property (nonatomic, assign) NSInteger friends_count;

/** 正在关注我的人--数量 */
@property (nonatomic, assign) NSInteger followers_count;

/** 我的推文总数 */
@property (nonatomic, assign) NSInteger statuses_count;

@end
