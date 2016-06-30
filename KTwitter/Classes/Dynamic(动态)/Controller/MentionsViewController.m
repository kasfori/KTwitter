//
//  MentionsViewController.m
//  KTwitter
//
//  Created by K on 16/6/15.
//  Copyright © 2016年 K. All rights reserved.
//

#import "MentionsViewController.h"
#import "TweetCell.h"
#import "Account.h"
#import "STTwitter.h"
#import "Tweet.h"
#import "LoadMoreFooter.h"
#import <MJExtension.h>
#import "UIView+Extension.h"

@interface MentionsViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *tweets;
@property (nonatomic, strong) Account *account;

@end

@implementation MentionsViewController

- (NSMutableArray *)tweets
{
    if (!_tweets) {
        self.tweets = [NSMutableArray array];
    }
    return _tweets;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self != nil){
        
        NSDictionary *data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"kAccessTokenKey"];
        NSString *token = [data valueForKey:@"oauth_token"];
        NSString *secret = [data valueForKey:@"oauth_token_secret"];
        self.account = [Account instancewithoAuthToken:token secret:secret];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 下拉刷新
    [self setupDownRefresh];
    
    // 上拉刷新
    [self setupUpRefresh];
    
}

/**
 *  上拉刷新
 */
- (void)setupUpRefresh
{
    LoadMoreFooter *footer = [LoadMoreFooter footer];
    footer.hidden = YES;
    self.tableView.tableFooterView = footer;
}

/**
 *  下拉刷新
 */
- (void)setupDownRefresh
{
    // 1.添加刷新控件
    UIRefreshControl *control = [[UIRefreshControl alloc] init];
    
    // 只有通过手动下拉刷新，才会触发UIControlEventValueChanged事件
    [control addTarget:self action:@selector(loadNewStatus:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:control];
    
    // 2.马上进入刷新状态(仅仅是显示刷新状态，并不会触发UIControlEventValueChanged事件)
    [control beginRefreshing];
    
    // 3.马上加载数据
    [self loadNewStatus:control];
}

/** 加载动态数据 */
- (void)loadNewStatus:(UIRefreshControl *)control
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    Tweet *firstTweet = [self.tweets firstObject];
    if (firstTweet) {
        // 若指定此参数，则返回ID比since_id大的推文（即比since_id时间晚的推文），默认为0
        params[@"since_id"] = firstTweet.id_str;
    }
    
    [self.account.twitter getMentionsTimelineSinceID:params[@"since_id"] count:20 successBlock:^(NSArray *statuses) {
        
        
        NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
        
        // 将最新的推文数据，添加到总数组的最前面
        NSRange range = NSMakeRange(0, newStatuses.count);
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tweets insertObjects:newStatuses atIndexes:set];

        [self.tableView reloadData];
        
        // 结束刷新刷新
        [control endRefreshing];
 
    } errorBlock:^(NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
        // 结束刷新刷新
        [control endRefreshing];
    }];
}

- (void)loadMoreStatus
{
        
        //NSLog(@"Success with username: %@ and userID: %@", username, userID);
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        // 取出最后面的推文（最新的推文，ID最大的推文）
        
        Tweet *lastTweet = [self.tweets lastObject];
        
        if (lastTweet) {
            // 若指定此参数，则返回ID小于或等于max_id的推文，默认为0。
            // id这种数据一般都是比较大的，一般转成整数的话，最好是long long类型
            NSString *maxID = [NSString stringWithFormat:@"%lld",lastTweet.id_str.longLongValue -1];
            params[@"max_id"] = maxID;
        }
        
        [self.account.twitter getStatusesMentionTimelineWithCount:@"30" sinceID:nil maxID:params[@"max_id"] trimUser:nil contributorDetails:nil includeEntities:nil successBlock:^(NSArray *statuses) {
            
            NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
            
            // 将更多的推文数据，添加到总数组的最后面
            [self.tweets addObjectsFromArray:newStatuses];
            
            // 刷新表格
            [self.tableView reloadData];
            
            // 结束刷新(隐藏footer)
            self.tableView.tableFooterView.hidden = YES;
            
        } errorBlock:^(NSError *error) {
            self.tableView.tableFooterView.hidden = YES;
        }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview datasource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TweetCell *cell = [TweetCell tweetcellWithTableView:tableView];
    Tweet *status = self.tweets[indexPath.row];
    cell.tweet = status;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Tweet *tweet = self.tweets[indexPath.row];
    return tweet.cellHeight;
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    // 如果tableView还没有数据，就直接返回
    if (self.tweets.count == 0 || self.tableView.tableFooterView.isHidden == NO) return;
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
