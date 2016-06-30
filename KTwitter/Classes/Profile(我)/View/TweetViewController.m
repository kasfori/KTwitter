//
//  TweetViewController.m
//  KTwitter
//
//  Created by K on 16/6/8.
//  Copyright © 2016年 K. All rights reserved.
//

#import "TweetViewController.h"

#import "TweetCell.h"
#import "MediaCell.h"
#import "MediaCell1.h"
#import "MediaCell2.h"
#import "MediaCell3.h"
#import "VideoCell.h"
#import <MJExtension.h>
#import "TweetDetailView.h"
#import "MediaDetailView.h"
#import "MediaDetailView1.h"
#import "MediaDetailView2.h"
#import "MediaDetailView3.h"
#import "VideoDetailView.h"
#import "LoadMoreFooter.h"
#import "STTwitter.h"
#import "Account.h"

#import "NewTweetViewController.h"
#import "Tweet.h"

#import "UIView+Extension.h"

@interface TweetViewController ()

@property (nonatomic, strong) Account *account;

@property (nonatomic, strong) NSMutableArray *statuses;
@end

@implementation TweetViewController

- (NSMutableArray *)statuses
{
    if (!_statuses) {
        self.statuses = [NSMutableArray array];
    }
    return _statuses;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    [self getUserTimeline];
    
    

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

- (void)getUserTimeline
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
    NSString *token = [data valueForKey:@"oauth_token"];
    NSString *secret = [data valueForKey:@"oauth_token_secret"];
    NSString *scrname = [data valueForKey:@"screen_name"];
    self.account = [Account instancewithoAuthToken:token secret:secret];

    [self.account.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        // 取出最前面的推文（最新的推文，ID最大的推文）
        Tweet *firstTweet = [self.statuses firstObject];
        if (firstTweet) {
            // 若指定此参数，则返回ID比since_id大的推文（即比since_id时间晚的推文），默认为0
            params[@"since_id"] = firstTweet.id_str;
        }
        // Get User timeline
        
        [self.account.twitter getUserTimelineWithScreenName:scrname sinceID:params[@"since_id"] maxID:nil count:30 successBlock:^(NSArray *statuses) {
 
            NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
            
            // 将最新的推文数据，添加到总数组的最前面
            NSRange range = NSMakeRange(0, newStatuses.count);
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
            [self.statuses insertObjects:newStatuses atIndexes:set];
            
            [self.tableView reloadData];


        }
             errorBlock:^(NSError *error) {
                 NSLog(@"Failed with error: %@", [error localizedDescription]);

             }];
        
        } errorBlock:^(NSError *error) {
            
        }];
    
}

- (void)loadMoreStatus
{
    
    [self.account.twitter verifyCredentialsWithUserSuccessBlock:^(NSString *username, NSString *userID) {
        
        //NSLog(@"Success with username: %@ and userID: %@", username, userID);
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        // 取出最后面的推文（最新的推文，ID最大的推文）
        
        Tweet *lastTweet = [self.statuses lastObject];
        
        if (lastTweet) {
            // 若指定此参数，则返回ID小于或等于max_id的推文，默认为0。
            // id这种数据一般都是比较大的，一般转成整数的话，最好是long long类型
            NSString *maxID = [NSString stringWithFormat:@"%lld",lastTweet.id_str.longLongValue -1];
            params[@"max_id"] = maxID;
        }
        // Get User timeline
        
        [self.account.twitter getStatusesUserTimelineForUserID:userID screenName:nil sinceID:nil count:@"30" maxID:params[@"max_id"] trimUser:nil excludeReplies:nil contributorDetails:nil includeRetweets:nil successBlock:^(NSArray *statuses) {
            
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
            
        }];
        
}


-(NSString *)segmentTitle
{
    return @"推文";
}

-(UIScrollView *)streachScrollView
{
    return self.tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.statuses.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Tweet *tweet = self.statuses[indexPath.row];
    return tweet.cellHeight;
    
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
