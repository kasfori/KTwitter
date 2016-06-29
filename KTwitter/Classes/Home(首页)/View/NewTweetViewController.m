//
//  NewTweetViewController.m
//  KTwitter
//
//  Created by K on 16/6/1.
//  Copyright © 2016年 K. All rights reserved.
//

#import "NewTweetViewController.h"
#import "Tweet.h"
#import "Account.h"
#import "UIImageView+AFNetworking.h"
#import "STTwitter.h"

@interface NewTweetViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *Cancel;
@property (weak, nonatomic) IBOutlet UIImageView *replyImage;
@property (weak, nonatomic) IBOutlet UILabel *replyLabel;
@property (weak, nonatomic) IBOutlet UITextView *statusText;
@property (weak, nonatomic) IBOutlet UILabel *statusTextCount;
@property (weak, nonatomic) IBOutlet UIButton *tweetButton;

@property (nonatomic, strong) Account *account;
@property (nonatomic, copy) Tweet *tweet;

@end

@implementation NewTweetViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
        NSString *token = [data valueForKey:@"oauth_token"];
        NSString *secret = [data valueForKey:@"oauth_token_secret"];
        self.account = [Account instancewithoAuthToken:token secret:secret];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.profileImage.layer.cornerRadius = 5;
    self.statusText.delegate = self;
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
    NSString *scrname = [data valueForKey:@"screen_name"];

    if (self.name) {
        
        self.replyImage.hidden = NO;
        self.replyLabel.hidden = NO;
        self.replyLabel.text = [NSString stringWithFormat:@"回复给 %@",self.name];
        self.statusText.text = [NSString stringWithFormat:@"@%@ ",self.scrName];
    } else {
        
        self.replyImage.hidden = YES;
        self.replyLabel.hidden = YES;
        self.statusText.text=@"";
        self.statusTextCount.text=@"140";
    }

        [self.account.twitter getUserInformationFor:scrname successBlock:^(NSDictionary *user) {
        [self.profileImage setImageWithURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]];
        } errorBlock:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    
    [self.statusText becomeFirstResponder];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    if(newLength > 140){
        return NO;
    }
    
    self.statusTextCount.text = [NSString stringWithFormat:@"%lu", 140 - newLength];
    
    return YES;
    
}
- (IBAction)onCancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
    
}
- (IBAction)onDone:(id)sender {
    
    //tweet
    NSString* status = self.statusText.text;
    [self.account.twitter postStatusUpdate:status inReplyToStatusID:nil latitude:nil longitude:nil placeID:nil displayCoordinates:nil trimUser:nil successBlock:^(NSDictionary *status) {
        NSLog(@"updated status");
        
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     
                                 }];
    } errorBlock:^(NSError *error) {
        NSLog(@"failed  status");
        [self dismissViewControllerAnimated:YES
                                 completion:^{
                                     
                                 }];
    }];
}

@end
