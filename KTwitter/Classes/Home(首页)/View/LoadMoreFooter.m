//
//  LoadMoreFooter.m
//  KTwitter
//
//  Created by K on 15/12/31.
//  Copyright © 2015年 K. All rights reserved.
//

#import "LoadMoreFooter.h"

@implementation LoadMoreFooter

+ (instancetype)footer
{
    return [[[NSBundle mainBundle] loadNibNamed:@"LoadMoreFooter" owner:nil options:nil] lastObject];
}

@end
