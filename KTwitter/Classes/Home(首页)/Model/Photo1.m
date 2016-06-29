//
////
////  Photo.m
////  KTwitter
////
////  Created by K on 16/1/20.
////  Copyright © 2016年 K. All rights reserved.
////
//
//#import "Photo.h"
////#import <MJExtension.h>
//
//@implementation Photo
//
////+ (NSDictionary *)mj_replacedKeyFromPropertyName
////{
////    return @{// return @{@"media" : @"extended_entities.media"}; tweet.m --> 所以这里只要 @"video_url" : @"video_info.variants[0].url"
////             
////             // ----m3u8 only ios   ----mp4  ------webm google  ----mpd
////             @"video_url" : @"video_info.variants[0].url"
////             };
////}
//
////+ (NSDictionary *)mj_replacedKeyFromPropertyName
////{
////    return @{//@"media" : @"extended_entities.media",
////             @"media_url" : @"media.media_url"
////
////
////             };
////}
//
//
////- (void)setType:(Type)type
////{
////    type = type;
////    
////    if(self.video_url != nil){
////        self.type = video;
////    } else {
////        self.type = photo;
////    }
////    
////    
////}
//
////-(Media*) initWithDictionary:(NSDictionary *) dict {
//////    self = [super init];
//////
//////    NSDictionary *dictionary = arrays[0];
////////    self.media_url = dictionary[@"media_url"];
//////
//////    NSDictionary *variant = [dictionary valueForKeyPath:@"video_info.variants"][0];
//////    self.video_url = variant[@"url"];
////    if(self.video_url != nil){
////        self.type = Video;
////    } else {
////        self.type = Photo;
////    }
////    return self;
////}
//
//
////variants =                         (
////                                    {
////                                        "content_type" = "application/dash+xml";
////                                        url = "https://video.twimg.com/ext_tw_video/687106847015223296/pu/pl/RZxDY3RAVrBi5f8s.mpd";
////                                    },
////                                    {
////                                        "content_type" = "application/x-mpegURL";
////                                        url = "https://video.twimg.com/ext_tw_video/687106847015223296/pu/pl/RZxDY3RAVrBi5f8s.m3u8";
////                                    },
////                                    {
////                                        bitrate = 320000;
////                                        "content_type" = "video/mp4";
////                                        url = "https://video.twimg.com/ext_tw_video/687106847015223296/pu/vid/180x320/Rb3nVOZBivI_iqiZ.mp4";
////                                    },
////                                    {
////                                        bitrate = 320000;
////                                        "content_type" = "video/webm";
////                                        url = "https://video.twimg.com/ext_tw_video/687106847015223296/pu/vid/180x320/Rb3nVOZBivI_iqiZ.webm";
////                                    }
////                                    );
//
//@end
