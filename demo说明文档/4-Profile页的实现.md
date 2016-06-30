# Profile页面的实现

![](https://raw.githubusercontent.com/kasfori/KTwitter/master/demo%E7%9B%B8%E5%85%B3%E6%88%AA%E5%9B%BE/Profile%E9%A1%B5%E7%9A%84%E5%AE%9E%E7%8E%B0.png)

#### Profile页面的结构

Profile页面分为上下两个部分，头部采用了一个`XIB`来显示个人信息，采用了`ARSegmentPage`框架来做下拉放大动画。下面自定义两个控制器，分别用来显示个人的推文和收藏。

头部控制器继承`ARSegmentPage`,在.m文件实现它的对象方法实现下拉放大效果，关键代码如下：

```

- (void)updateHeadPhotoWithTopInset:(CGFloat)inset {
    CGFloat ratio = (inset - 64)/200.0;
    self.bottomConstraint.constant = ratio * 40 + 78;
    //self.widthConstraint.constant = 8 + ratio * 60;
}

``` 
然后在`XIB`设置背景图片的高度固定，添加一条到容器底部的约束，如图：
![](https://raw.githubusercontent.com/kasfori/KTwitter/master/demo%E7%9B%B8%E5%85%B3%E6%88%AA%E5%9B%BE/Profile%E5%A4%B4%E9%83%A8%E7%BA%A6%E6%9D%9F.png)


#### 显示推文和收藏控制器

新建推文和收藏控制器，实现`ARSegmentPage`的代理协议`ARSegmentControllerDelegate`的`segmentTitle`和`streachScrollView`方法，用来设置控制器的`title`和一个最高高度在头部控制器底下的`tableView`。

关键代码如下：

```
-(NSString *)segmentTitle
{
    return @"推文";
}

-(UIScrollView *)streachScrollView
{
    return self.tableView;
}

```

然后在控制器实现推文的请求数据以便显示，同样是通过`STTwitter`相关API发送数据请求，代码如下：

```
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

```

收藏控制器实现原理与上面一致，只是控制器的`title`和请求数据的API有所不同。