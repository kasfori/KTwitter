//
//  HomeViewController.m
//  KTwitter
//
//  Created by K on 15/12/22.
//  Copyright © 2015年 K. All rights reserved.
//
#import "HomeViewController.h"
#import "STTwitter.h"
#import "UIView+Extension.h"
#import "Account.h"
#import "Tweet.h"
#import <MJExtension.h>
#import <UIImageView+WebCache.h>
#import "LoadMoreFooter.h"

#import "TweetCell.h"
#import "MediaCell.h"
#import "MediaCell1.h"
#import "MediaCell2.h"
#import "MediaCell3.h"
#import "VideoCell.h"

#import "TweetDetailView.h"
#import "MediaDetailView.h"
#import "MediaDetailView1.h"
#import "MediaDetailView2.h"
#import "MediaDetailView3.h"
#import "VideoDetailView.h"

#import "NewTweetViewController.h"
#import "TweetsTool.h"

@interface HomeViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *statuses;
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

-(Account *)account
{
    if (!_account) {
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
        NSString *token = [data valueForKey:@"oauth_token"];
        NSString *secret = [data valueForKey:@"oauth_token_secret"];
        self.account = [Account instancewithoAuthToken:token secret:secret];
    }
    return _account;
}

- (IBAction)newTweet:(UIBarButtonItem *)sender {
    NewTweetViewController *controller = [[NewTweetViewController alloc] init];
    [self.navigationController presentViewController:controller animated:YES completion:^{
    }];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];

    // 集成下拉刷新控件
    [self setupDownRefresh];
    
    // 集成上拉刷新控件
    [self setupUpRefresh];

}

/**
 *  上拉刷新控件
 */
- (void)setupUpRefresh
{
    LoadMoreFooter *footer = [LoadMoreFooter footer];
    footer.hidden = YES;
    self.tableView.tableFooterView = footer;
}

/**
 *  下拉刷新控件
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
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 取出最前面的推文（最新的推文，ID最大的推文）
    Tweet *firstTweet = [self.statuses firstObject];
    if (firstTweet) {
        // 若指定此参数，则返回ID比since_id大的推文（即比since_id时间晚的推文），默认为0
        params[@"since_id"] = firstTweet.id_str;
    }
    // 定义一个block处理返回的字典数据
    void (^dealingResult)(NSArray *) = ^(NSArray *statuses){
        
        NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
        
        // 将最新的推文数据，添加到总数组的最前面
        NSRange range = NSMakeRange(0, newStatuses.count);
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.statuses insertObjects:newStatuses atIndexes:set];
        
        //NSLog(@"-- statuses: %@", statuses);
        
        [self.tableView reloadData];
        
        // 结束
        [control endRefreshing];
        
        // 显示新推文
        [self showNewStatusCount:newStatuses.count];
    };

    NSArray *tweets = [TweetsTool tweetsWithParams:params];
    if (tweets.count) {
        dealingResult(tweets);
    } else {

    // Get Home timeline
    [self.account.twitter getHomeTimelineSinceID:params[@"since_id"]
                                           count:30
                                    successBlock:^(NSArray *statuses) {
                                        
                                    [TweetsTool saveTweets:statuses];
                                        
                                    dealingResult(statuses);
                                        
                                    }
                                      errorBlock:^(NSError *error) {
                                      NSLog(@"Failed with error: %@", [error localizedDescription]);
                                      // 结束刷新刷新
                                      [control endRefreshing];
                                      }];
    }
}
/**
 *  加载更多推文数据
 */
- (void)loadMoreStatus
{
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        // 取出最后面的推文（最新的推文，ID最大的推文）
        
        Tweet *lastTweet = [self.statuses lastObject];

        if (lastTweet) {
            // 若指定此参数，则返回ID小于或等于max_id的推文，默认为0。
            // id这种数据一般都是比较大的，一般转成整数的话，最好是long long类型
            NSString *maxID = [NSString stringWithFormat:@"%lld",lastTweet.id_str.longLongValue -1];
            params[@"max_id"] = maxID;
        }
    // 处理字典数据
    void (^dealingResult)(NSArray *) = ^(NSArray *statuses) {
        
        NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
        
        // 将更多的推文数据，添加到总数组的最后面
        [self.statuses addObjectsFromArray:newStatuses];
        
        // 刷新表格
        [self.tableView reloadData];
        
        // 结束刷新(隐藏footer)
        self.tableView.tableFooterView.hidden = YES;
    };
    
    NSArray *tweets = [TweetsTool tweetsWithParams:params];
    if (tweets.count) {
        dealingResult(tweets);
    } else {
        // Get Home timeline
        [self.account.twitter getStatusesHomeTimelineWithCount:@"30" sinceID:nil maxID:params[@"max_id"] trimUser:nil excludeReplies:nil contributorDetails:nil includeEntities:nil successBlock:^(NSArray *statuses) {
            
            [TweetsTool saveTweets:statuses];
            dealingResult(statuses);
            
        } errorBlock:^(NSError *error) {
            self.tableView.tableFooterView.hidden = YES;
            NSLog(@"Failed with error: %@", [error localizedDescription]);
        }];
    }
}
/**
 *  显示最新推文数量
 *
 *  @param count 最新推文的数量
 */
- (void)showNewStatusCount:(NSUInteger)count
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
        label.text = [NSString stringWithFormat:@"共有%lu条新的推文", (unsigned long)count];
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
    Tweet *tweet = self.statuses[indexPath.row];

    if (tweet.video_url != nil) {
        VideoCell *cell = [VideoCell videoTweetcellWithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
        __block VideoCell *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name, NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };
        
        return cell;
        
    } else if(tweet.media_url3 != nil){
        MediaCell3 *cell = [MediaCell3 mediaTweetcell3WithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
        __block MediaCell3 *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name, NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };
        
        return cell;
        
    } else if (tweet.media_url2 != nil){
        MediaCell2 *cell = [MediaCell2 mediaTweetcell2WithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
        __block MediaCell2 *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name, NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };
        
        return cell;
        
    } else if(tweet.media_url1 != nil){
        MediaCell1 *cell = [MediaCell1 mediaTweetcell1WithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
        __block MediaCell1 *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name, NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };
        
        return cell;
        
    } else if(tweet.media_url0 != nil){
        
        MediaCell *cell = [MediaCell mediaTweetcellWithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
         __block MediaCell *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name, NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };

        return cell;
    } else {
        TweetCell *cell = [TweetCell tweetcellWithTableView:tableView];
        Tweet *status = self.statuses[indexPath.row];
        cell.tweet = status;
        
//        cell.BtnBlock = ^(){
//
//            [self pushToNewPage];
//        };
        
        //cell.delegate = self;
        
        
        
        __block TweetCell *weakCell = cell;
        cell.ButtnBlock = ^(NSString *name,NSString *scrName){
            NewTweetViewController *controller = [[NewTweetViewController alloc] init];
            controller.name = weakCell.tweet.user.name;
            controller.scrName = weakCell.tweet.user.screen_name;
            [self.navigationController presentViewController:controller animated:YES completion:^{
            }];
        };
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.statuses[indexPath.row];
    
    if (tweet.media_url0 != nil && tweet.video_url != nil) {
        
        VideoDetailView *mvc = [[VideoDetailView alloc] initWithNibName:@"VideoDetailView" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        mvc.tweet = tweet;
        [self.navigationController pushViewController:mvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;
        
    } else if (tweet.media_url3 != nil){

        MediaDetailView3 *mvc = [[MediaDetailView3 alloc] initWithNibName:@"MediaDetailView3" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        mvc.tweet = tweet;
        [self.navigationController pushViewController:mvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;
 
    } else if (tweet.media_url2 != nil){
        
        MediaDetailView2 *mvc = [[MediaDetailView2 alloc] initWithNibName:@"MediaDetailView2" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        mvc.tweet = tweet;
        [self.navigationController pushViewController:mvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;
        
    } else if (tweet.media_url1 != nil){
        
        MediaDetailView1 *mvc = [[MediaDetailView1 alloc] initWithNibName:@"MediaDetailView1" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        mvc.tweet = tweet;
        [self.navigationController pushViewController:mvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;
        
    } else if(tweet.media_url0 != nil && tweet.video_url == nil){
        
        MediaDetailView *tvc = [[MediaDetailView alloc] initWithNibName:@"MediaDetailView" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        tvc.tweet = tweet;
        [self.navigationController pushViewController:tvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;
        
        
    } else {
        TweetDetailView *tvc = [[TweetDetailView alloc] initWithNibName:@"TweetDetailView" bundle:nil];
        Tweet *tweet = self.statuses[indexPath.row];
        tvc.tweet = tweet;
        [self.navigationController pushViewController:tvc animated:YES];
        [tableView  deselectRowAtIndexPath:indexPath  animated:YES];
        return;

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.statuses[indexPath.row];
    return tweet.cellHeight;
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
