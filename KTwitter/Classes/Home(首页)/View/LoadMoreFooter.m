//
//  LoadMoreFooter.m
//  KTwitter
//
//  Created by K on 15/12/31.
//  Copyright © 2015年 K. All rights reserved.
//

#import "LoadMoreFooter.h"

@implementation LoadMoreFooter

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)footer
{
    return [[[NSBundle mainBundle] loadNibNamed:@"LoadMoreFooter" owner:nil options:nil] lastObject];
}

@end
