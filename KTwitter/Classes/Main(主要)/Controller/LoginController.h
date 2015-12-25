//
//  LoginController.h
//  KTwitter
//
//  Created by K on 15/12/25.
//  Copyright © 2015年 K. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController



- (IBAction)loginWeb:(id)sender;

- (void)setOAuthToken:(NSString *)token oauthVerifier:(NSString *)verifier;


@end
