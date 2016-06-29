//
//  MeViewController.m
//  KTwitter
//
//  Created by K on 16/6/8.
//  Copyright © 2016年 K. All rights reserved.
//

#import "MeViewController.h"
#import "ProfileViewController.h"

@interface MeViewController ()

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ProfileViewController *vc = [[ProfileViewController alloc] init];

    [self addChildViewController:vc];
    [self.view addSubview:vc.view];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
