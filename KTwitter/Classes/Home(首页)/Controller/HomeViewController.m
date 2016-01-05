//
//  HomeViewController.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//

#import "HomeViewController.h"
#import <STTwitter.h>
#import "UIView+Extension.h"
#import "LoginController.h"
#import "Account.h"
#import "User.h"
#import "Tweet.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "LoadMoreFooter.h"
#import <AFNetworking.h>

@interface HomeViewController ()

/**
 *  推文数组（里面放的都是tweet模型，一个Status对象就代表一条tweet）
 */
@property (nonatomic, strong) NSMutableArray *statuses;

@property (nonatomic, strong) STTwitterAPI *twitter;

@property (nonatomic, strong) Account *account;

@end

@implementation HomeViewController

- (NSMutableArray *)statuses
{
    if (!_statuses) {
        self.statuses = [NSMutableArray array];
    }
    return _statuses;
}

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
    
    // 集成下拉刷新控件
    [self setupDownRefresh];
    
    // 集成上拉刷新控件
    [self setupUpRefresh];
}

/**
 *  集成上拉刷新控件
 */
- (void)setupUpRefresh
{
    LoadMoreFooter *footer = [LoadMoreFooter footer];
    footer.hidden = YES;
    self.tableView.tableFooterView = footer;
}

/**
 *  集成下拉刷新控件
 */
- (void)setupDownRefresh
{
    // 1.添加刷新控件
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    
    // 只有用户通过手动下拉刷新，才会触发UIControlEventValueChanged事件
    [control addTarget:self action:@selector(loadNewStatus:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    
    // 2.马上进入刷新状态(仅仅是显示刷新状态，并不会触发UIControlEventValueChanged事件)
    [control beginRefreshing];
    
    // 3.马上加载数据
    [self loadNewStatus:control];
}

/** 加载推文 */
- (void)loadNewStatus:(UIRefreshControl *)control
{
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                            consumerSecret:twitterConsumerSecret
                                                oauthToken:self.account.access_token
                                          oauthTokenSecret:self.account.accessToken_secret];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        //NSLog(@"Success with username: %@ and userID: %@", username, userID);
        
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
 
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"access_token"] = self.account.access_token;
            
            // 取出最前面的推文（最新的推文，ID最大的推文）
            Tweet *firstTweet = [self.statuses firstObject];
            if (firstTweet) {
                // 若指定此参数，则返回ID比since_id大的推文（即比since_id时间晚的推文），默认为0
                params[@"since_id"] = firstTweet.id_str;
            }
        // Get Home timeline
        [self.twitter getHomeTimelineSinceID:params[@"since_id"]
                                  count:20
                           successBlock:^(NSArray *statuses) {
 
                               NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
                               
                               // 将最新的推文数据，添加到总数组的最前面
                               NSRange range = NSMakeRange(0, newStatuses.count);
                               NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
                               [self.statuses insertObjects:newStatuses atIndexes:set];
                               
//                               NSLog(@"-- statuses: %@", statuses);
                               
                               [self.tableView reloadData];
                               
                               // 结束刷新刷新
                               [control endRefreshing];
                               
                               // 显示最新微博的数量
                               int count = (int)[newStatuses count];
                               [self showNewStatusCount:count];
                             }
                             errorBlock:^(NSError *error) {
                                 NSLog(@"Failed with error: %@", [error localizedDescription]);
                                 // 结束刷新刷新
                                 [control endRefreshing];
                             }];        
    } errorBlock:^(NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
}

/**
 *  加载更多推文数据
 */
- (void)loadMoreStatus
{
    
    self.twitter = [STTwitterAPI twitterAPIWithOAuthConsumerKey:twitterConsumerKey
                                                 consumerSecret:twitterConsumerSecret
                                                     oauthToken:self.account.access_token
                                               oauthTokenSecret:self.account.accessToken_secret];
    
    [self.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        //NSLog(@"Success with username: %@ and userID: %@", username, userID);

        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"access_token"] = self.account.access_token;
        
        // 取出最后面的推文（最新的推文，ID最大的推文）
        //Tweet *lastTweet = self.statuses[[self.statuses count] - 1 ];
        Tweet *lastTweet = [self.statuses lastObject];

        if (lastTweet) {
            // 若指定此参数，则返回ID小于或等于max_id的微博，默认为0。
            // id这种数据一般都是比较大的，一般转成整数的话，最好是long long类型
            NSString *maxID = [NSString stringWithFormat:@"%lld",lastTweet.id_str.longLongValue -1];
            params[@"max_id"] = maxID;
        }
        // Get Home timeline
        
        [self.twitter getStatusesHomeTimelineWithCount:@"100" sinceID:nil maxID:params[@"max_id"] trimUser:nil excludeReplies:nil contributorDetails:nil includeEntities:nil successBlock:^(NSArray *statuses) {
            
                NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
    
                // 将更多的推文数据，添加到总数组的最后面
                [self.statuses addObjectsFromArray:newStatuses];
    
                // 刷新表格
                [self.tableView reloadData];
    
                // 结束刷新(隐藏footer)
                self.tableView.tableFooterView.hidden = YES;
            
        } errorBlock:^(NSError *error) {
            
                  self.tableView.tableFooterView.hidden = YES;
                  NSLog(@"Failed with error: %@", [error localizedDescription]);
        }];
    } errorBlock:^(NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
    }];
}

/**
 *  显示最新推文数量
 *
 *  @param count 最新微博的数量
 */
- (void)showNewStatusCount:(int)count
{
    // 1.创建label
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"timeline_new_status_background"]];
    label.width = [UIScreen mainScreen].bounds.size.width;
    label.height = 16;
    
    // 2.设置其他属性
    if (count == 0) {
        label.text = @"没有新的推文，稍后再试";
    } else {
        label.text = [NSString stringWithFormat:@"共有%d条新的推文", count];
    }
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    
    // 3.添加
    label.y = 64 - label.height;
    // 将label添加到导航控制器的view中，并且是盖在导航栏下边
    [self.navigationController.view insertSubview:label belowSubview:self.navigationController.navigationBar];
    
    // 4.动画
    // 先利用1s的时间，让label往下移动一段距离
    CGFloat duration = 1.0; // 动画的时间
    [UIView animateWithDuration:duration animations:^{
     
        label.transform = CGAffineTransformMakeTranslation(0, label.height);
    } completion:^(BOOL finished) {
        // 延迟1s后，再利用1s的时间，让label往上移动一段距离（回到一开始的状态）
        CGFloat delay = 1.0; // 延迟1s
        // UIViewAnimationOptionCurveLinear:匀速
        [UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveLinear animations:^{
            
            label.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [label removeFromSuperview];
        }];
    }];
    // 如果某个动画执行完毕后，又要回到动画执行前的状态，用transform来做动画
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.statuses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"status";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    // 取出这行对应的推文字典
    Tweet *status = self.statuses[indexPath.row];
    
    // 取出这条推文的作者（用户）
    User *user = status.user;
    cell.textLabel.text = user.name;
    
    // 设置推文文字
    cell.detailTextLabel.text = status.text;
    
    // 设置头像
    UIImage *placehoder = [UIImage imageNamed:@"bg_texture"];
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.profile_image_url] placeholderImage:placehoder];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    // 如果tableView还没有数据，就直接返回
    if (self.statuses.count == 0 || self.tableView.tableFooterView.isHidden == NO) return;
    //    if ([self.tableView numberOfRowsInSection:0] == 0) return;
    
    // 当最后一个cell完全显示在眼前时，contentOffset的y值
    CGFloat judgeOffsetY = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.height - self.tableView.tableFooterView.height;
    if (offsetY >= judgeOffsetY) { // 最后一个cell完全进入视野范围内
        // 显示footer
        self.tableView.tableFooterView.hidden = NO;
        
        // 加载更多的推文
        [self loadMoreStatus];
    }
}

@end
