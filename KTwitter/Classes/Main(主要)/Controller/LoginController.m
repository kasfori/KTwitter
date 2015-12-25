//
//  LoginController.m
//  KTwitter
//
//  Created by K on 15/12/25.
//  Copyright © 2015年 K. All rights reserved.
//

#import "LoginController.h"
#import "STTwitter.h"
#import "MainTabBarController.h"



NSString *const twitterConsumerKey = @"fnqM9ctoYFUvgdCdafTg";
NSString *const twitterConsumerSecret = @"HRzhFm3QNg4GOl9blL2Bvv2lBY31SZEhRMUaCjdQ0Mo";

@interface LoginController ()

@property (nonatomic, strong) STTwitterAPI *twitter;

@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)loginWeb:(id)sender {
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                                 consumerSecret:twitterConsumerSecret];
    
    [_twitter postTokenRequest:^(NSURL *url, NSString *oauthToken) {
        
        NSLog(@"-- url: %@", url);
        NSLog(@"-- oauthToken: %@", oauthToken);
        
        [[UIApplication sharedApplication] openURL:url];
        
        UIStoryboard *board = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        UIViewController *MainTabBar = [board instantiateViewControllerWithIdentifier:@"MainTabBar"];
        
        [self presentViewController:MainTabBar animated:YES completion:nil];
        
    } authenticateInsteadOfAuthorize:NO
                    forceLogin:@(YES)
                    screenName:nil
                 oauthCallback:@"myapp://"
                    errorBlock:^(NSError *error) {
                        NSLog(@"-- error: %@", error);
                    }];
}

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier
{
    
    [self.twitter postAccessTokenRequestWithPIN:verifier successBlock:^(NSString *oauthToken, NSString *oauthTokenSecret, NSString *userID, NSString *screenName) {
        NSLog(@"-- screenName: %@  --  userID: %@", screenName ,userID);
        
    } errorBlock:^(NSError *error) {
        
        NSLog(@"-- %@", [error localizedDescription]);
    }];
}

@end
