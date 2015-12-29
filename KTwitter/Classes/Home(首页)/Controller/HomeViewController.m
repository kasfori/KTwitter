//
//  HomeViewController.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "HomeViewController.h"
#import <STTwitter.h>
#import "LoginController.h"
#import "Account.h"

@interface HomeViewController ()

/** 存储推文 */
@property (nonatomic, strong) NSArray *statuses;

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, strong) Account *account;

@end

@implementation HomeViewController


- (Account *)account
{
    if (!_account) {
        // 沙盒
        NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [doc stringByAppendingPathComponent:@"account.archive"];
        _account = [NSKeyedUnarchiver unarchiveObjectWithFile:path];

    }
    return _account;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadstatuses];

}

/** 加载推文 */
-(void)loadstatuses
{
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                            consumerSecret:twitterConsumerSecret
                                                oauthToken:self.account.access_token
                                          oauthTokenSecret:self.account.accessToken_secret];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSLog(@"Success with username: %@ and userID: %@", username, userID);
        
        // GetUserTimeline
        //        [twitter getUserTimelineWithScreenName:screenName
        //                                  successBlock:^(NSArray *statuses) {
        //                                      NSLog(@"Statuses: %@", statuses);
        //
        //                                  }
        //                                    errorBlock:^(NSError *error) {
        //                                      NSLog(@"Failed with error: %@", [error localizedDescription]);
        //                                  }];
        
        // GetUserTimeline with count
        //        [twitter getUserTimelineWithScreenName:screenName
        //                                         count:50
        //                                  successBlock:^(NSArray *statuses) {
        //                                      NSLog(@"Statuses: %@", statuses);
        //                                  }
        //                                    errorBlock:^(NSError *error) {
        //                                        NSLog(@"Failed with error: %@", [error localizedDescription]);
        //                                    }];
        
        // Get Home timeline
        [self.twitter getHomeTimelineSinceID:nil
                                  count:2
                           successBlock:^(NSArray *statuses) {
 
                               self.statuses = statuses;
                               
                               NSLog(@"-- statuses: %@", statuses);
                               
                           }
                             errorBlock:^(NSError *error) {
                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                             }];
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
}

@end
