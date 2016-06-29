//
//  Tweet.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "Tweet.h"
#import "NSDate+Extension.h"
#import <MJExtension.h>
#import "TweetPhoto.h"

@implementation Tweet

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{

    return @{
             @"ID" : @"id",
             @"media_url0" : @"extended_entities.media[0].media_url",
             @"media_url1" : @"extended_entities.media[1].media_url",
             @"media_url2" : @"extended_entities.media[2].media_url",
             @"media_url3" : @"extended_entities.media[3].media_url",

             // variants[0]>m3u8 only ios   variants[1]>mp4  variants[2]>webm google  variants[3]>mpd
              @"video_url" : @"extended_entities.media[0].video_info.variants[0].url"
             };
}

- (NSString *)created_at
{
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    // 如果是真机调试，转换这种欧美时间，需要设置locale
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    // 设置日期格式（声明字符串里面每个数字和单词的含义）
    // E:星期几
    // M:月份
    // d:几号(这个月的第几天)
    // H:24小时制的小时
    // m:分钟
    // s:秒
    // y:年
    fmt.dateFormat = @"EEE MMM dd HH:mm:ss Z yyyy";
    //    _created_at = @"Tue Sep 30 17:06:25 +0600 2014";
    
    // 微博的创建日期
    NSDate *createDate = [fmt dateFromString:_created_at];
    // 当前时间
    NSDate *now = [NSDate date];
    
    // 日历对象（方便比较两个日期之间的差距）
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 计算两个日期之间的差值
    NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];
    
    if ([createDate isThisYear]) { // 今年
        if ([createDate isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:createDate];
        } else if ([createDate isToday]) { // 今天
            if (cmps.hour >= 1) {
                return [NSString stringWithFormat:@"%d小时前", (int)cmps.hour];
            } else if (cmps.minute >= 1) {
                return [NSString stringWithFormat:@"%d分钟前", (int)cmps.minute];
            } else {
                return @"刚刚";
            }
        } else { // 今年的其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:createDate];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:createDate];
    }
}


@end
