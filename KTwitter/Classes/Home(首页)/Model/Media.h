//
//  Media.h
//  KTwitter
//
//  Created by K on 15/12/29.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MediaType {
    Photo,
    Video
};

@interface Media : NSObject

/** 推文的图片 如果没有图片 字段为空*/
@property (strong, nonatomic) NSString * mediaUrl;

/** 推文的视频 如果没有视频 字段为空*/
@property (strong, nonatomic) NSString * videoUrl;


@property (assign, nonatomic) enum MediaType type;

-(Media*) initWithDictionary:(NSArray*) dictionary;

@end
