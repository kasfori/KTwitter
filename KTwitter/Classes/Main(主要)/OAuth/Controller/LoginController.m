//
//  LoginController.m
//  KTwitter
//
//  Created by K on 15/12/25.
//  Copyright © 2015年 K. All rights reserved.
//

#import "LoginController.h"
#import "MainTabBarController.h"
#import "STTwitterAPI.h"
#import "HomeViewController.h"

////官方key
//#define TWITTER_CONSUMER_KEY @"IQKbtAYlXLripLGPWd0HUA"
//#define TWITTER_CONSUMER_SECRET @"GgDYlkSvaPxGxC4X8liwpUoqKwwr3lCADbz8A7ADU"

#define TWITTER_CONSUMER_KEY @"LtDZT4MSUZalnz9CbGZSs2tCH"
#define TWITTER_CONSUMER_SECRET @"IjAp2rOMnVCO4zRgSYDmanTybDvPFAEMKsbzHsSdpXwKVk2CA3"


@interface LoginController ()

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)loginWeb:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:TWITTER_CONSUMER_KEY
                                                 consumerSecret:TWITTER_CONSUMER_SECRET];
    
    [self.twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        
        [[UIApplication sharedApplication] openURL:url];
        
        //[self performSelector:@selector(haha) withObject:sender afterDelay:2];
        if (url) {
              [self haha];
        }
        
      
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://"
                    errorBlock:^(NSError *error) {

                        NSLog(@"-- error: %@", error);
                    }];

}


- (void)haha
{
    
    UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    UIViewController *MainTabBar = [board instantiateViewControllerWithIdentifier:@"MainTabBar"];
    
    [self presentViewController:MainTabBar animated:YES completion:nil];
    
}


- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier
{
    
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
//        NSLog(@"-- screenName: %@  --  userID: %@ --AccessToken: %@  --AccessTokenSecret: %@", screenName ,userID,oauthToken,oauthTokenSecret);
      
        NSDictionary *data = @{     @"oauth_token" : oauthToken,
                                    @"oauth_token_secret" : oauthTokenSecret,
                                    @"user_id" : userID,
                                    @"screen_name" : screenName,
                                    @"oauth_verifier" : verifier
                                    
                                    };
    
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"kAccessTokenKey"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"-- %@", [error localizedDescription]);
    }];
    
}

@end
