# Dynamic页面的实现

![](https://raw.githubusercontent.com/kasfori/KTwitter/master/demo%E7%9B%B8%E5%85%B3%E6%88%AA%E5%9B%BE/Dynamic%E9%A1%B5%E7%9A%84%E5%AE%9E%E7%8E%B0.png)

#### 加载数据、上拉、下拉

程序切换到`Dynamic`页，直接调用`setupDownRefresh`方法，方法里面创建了一个`UIRefreshControl`控制器，通过控制器来控制用户手动下拉刷新和进入`Dynamic`页即刻刷新的状态，里面调用了`loadNewStatus`方法来加载自己的动态数据，在`viewDidLoad `方法中调用，代码如下：

```
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    // 下拉刷新
    [self setupDownRefresh];
    
    // 上拉刷新
    [self setupUpRefresh];
    
}


```


进入`Dynamic`页显示个人动态代码：

```

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

```

下拉加载更多动态推文代码：

```objective-c
- (void)loadNewStatus:(UIRefreshControl *)control
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    Tweet *firstTweet = [self.tweets firstObject];
    if (firstTweet) {
        // 若指定此参数，则返回ID比since_id大的动态推文（即比since_id时间晚的动态推文），默认为0
        params[@"since_id"] = firstTweet.id_str;
    }
    
    [self.account.twitter getMentionsTimelineSinceID:params[@"since_id"] count:20 successBlock:^(NSArray *statuses) {
        
        
        NSArray *newStatuses = [Tweet mj_objectArrayWithKeyValuesArray:statuses];
        
        // 将最新的动态推文数据，添加到数组的最前面
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
```
