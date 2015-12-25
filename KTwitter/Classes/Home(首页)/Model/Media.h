//
//  Media.h
//  KTwitter
//
//  Created by K on 15/12/23.
//  Copyright © 2015年 K. All rights reserved.
//

#import <Foundation/Foundation.h>

enum MediaType {
    Photo,
    Video
};

@interface Media : NSObject

@property (strong, nonatomic) NSString * mediaUrl;
@property (strong, nonatomic) NSString * videoUrl;
@property (assign, nonatomic) enum MediaType type;

-(Media*) initWithDictionary:(NSArray*) dictionary;

@end
