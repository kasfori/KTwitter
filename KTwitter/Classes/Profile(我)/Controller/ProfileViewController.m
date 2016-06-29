//
//  ProfileViewController.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfileCell.h"
#import "UIImage+ImageEffects.h"
#import "TweetViewController.h"
#import "MediaViewController.h"
#import "FavoriteViewController.h"
#import "UIView+Extension.h"

void *ProfileCellInsetObserver = &ProfileCellInsetObserver;


@interface ProfileViewController ()

@property (nonatomic, strong) ProfileCell *header;



@end

@implementation ProfileViewController

-(instancetype)init
{
 
    TweetViewController *tweetTable = [[TweetViewController alloc] initWithNibName:@"TweetViewController" bundle:nil];
    //MediaViewController *mediaTable = [[MediaViewController alloc] initWithNibName:@"MediaViewController" bundle:nil];
    FavoriteViewController *favTable = [[FavoriteViewController alloc] initWithNibName:@"FavoriteViewController" bundle:nil];
    
    
    self = [super initWithControllers:tweetTable,favTable, nil];
    if (self) {
        // 图片距离顶部最小距离
        self.segmentMiniTopInset = 45;
        
        //图片的高度
        self.headerHeight = 210;
    }
    return self;
}


#pragma mark - override

-(UIView<ARSegmentPageControllerHeaderProtocol> *)customHeaderView
{
    if (_header == nil) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"ProfileCell" owner:nil options:nil] lastObject];
        _header.backgroundColor = [UIColor whiteColor];
    }
    return _header;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.navigationBar.hidden = YES;
    [self addObserver:self forKeyPath:@"segmentTopInset" options:NSKeyValueObservingOptionNew context:ProfileCellInsetObserver];
    
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    if (context == ProfileCellInsetObserver) {
        CGFloat inset = [change[NSKeyValueChangeNewKey] floatValue];
        [self.header updateHeadPhotoWithTopInset:inset];
    }
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"segmentTopInset"];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
