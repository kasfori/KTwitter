# Home页的实现

![](https://raw.githubusercontent.com/kasfori/KTwitter/master/demo%E7%9B%B8%E5%85%B3%E6%88%AA%E5%9B%BE/Home%E9%A1%B5%E7%9A%84%E5%AE%9E%E7%8E%B0.png)

#### 1、发推文

发推文通过调用`NewTweetViewController`控制器来性实现.

自定义`NewTweetViewController`控制器，在点击Home页发推文按钮的时候，弹出发推文控制器，显示已登陆用户的头像，用户名等，关键代码如下：

```objective-c
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
```



#### 2、Cell的实现

![](https://raw.githubusercontent.com/kasfori/KTwitter/master/demo%E7%9B%B8%E5%85%B3%E6%88%AA%E5%9B%BE/Cell.png)

如图,Cell使用`Xib`创建.使用`autolayout`,设置各控件间距,并将显示推文文字的label设置为numberOfLines=0，高度不设置。以此实现文字的自动换行。Cell其他对应位置的控件数据通过set方法来设置，代码如下：

```objective-c
- (void)setTweet:(Tweet *)tweet
{
    _tweet = tweet;
    User *user = tweet.user;
    
    if (self.tweet.retweeted_status) {
        tweet = tweet.retweeted_status;
        self.retweetedLabel.text = [NSString stringWithFormat:@"%@  转推了",user.name];
        
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweeted_status.favorite_count];
        self.likeCountLabel.hidden = [self.tweet.retweeted_status.favorite_count intValue] == 0;
        
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", self.tweet.retweeted_status.retweet_count];
        self.retweetCountLabel.hidden = [self.tweet.retweeted_status.retweet_count intValue] == 0;
        
        self.retweetedLabel.hidden = NO;
        self.retweetedImage.hidden = NO;
    } else {
        self.likeCountLabel.text = [NSString stringWithFormat:@"%@", tweet.favorite_count];
        self.likeCountLabel.hidden = [tweet.favorite_count intValue] == 0;
        
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%@", tweet.retweet_count];
        self.retweetCountLabel.hidden = [tweet.retweet_count intValue] == 0;
        self.retweetedLabel.hidden = YES;
        self.retweetedImage.hidden = YES;
        
    }

        UIImage *placehoder = [UIImage imageNamed:@"bg_texture"];
        [self.profileImage sd_setImageWithURL:[NSURL URLWithString:tweet.user.profile_image_url] placeholderImage:placehoder];
        self.profileImage.layer.cornerRadius = 5;
        self.nameLabel.text = tweet.user.name;
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@",tweet.user.screen_name];
        self.tweetTextLabel.text = tweet.text;
        self.createdAtLabel.text = tweet.created_at;
    
        [self layoutIfNeeded];
        self.tweet.cellHeight = CGRectGetMaxY(self.buttonsView.frame) + 10;
    
}

```


Cell中的媒体部分，显示图片的调用了`MJPhotoBrowser`框架，视频播放调用了`LSPlayer`框架,关键代码如下：

图片浏览：

```objective-c

- (void)photoTap:(UITapGestureRecognizer *)tap
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:self.tweet.media_url0, nil];
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:array.count];
    
    for (int i = 0; i < array.count; i--) {
        MJPhoto *photo = [[MJPhoto alloc] init]; 
        photo.url = [NSURL URLWithString:self.tweet.media_url0];
        photo.srcImageView = self.mediaView.subviews[i];
        [photos addObject:photo];
    }    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}
```

视频播放：

```objective-c
- (void)videoTap:(UITapGestureRecognizer *)tap
{
    LSPlayerView* playerView = [LSPlayerView playerView];
    playerView.currentFrame = self.mediaView.frame;
    playerView.tempSuperView = self.superview.superview;
    playerView.videoURL=self.tweet.video_url;
}

```


Cell中的回复按钮定义了一个block来实现业务逻辑，block设置两个参数，`username`和`screen_name`，用来传递当前推文的用户信息，点击回复按钮，执行block，跳转到发推文控制器`NewTweetViewController`，将当前的用户信息传递过去显示在相应的控件中。

.h文件

```objective-c
#import <UIKit/UIKit.h>

typedef void (^ButtnBlock)(NSString *name , NSString *scrName);

@interface TweetCell : UITableViewCell

@property (nonatomic, copy) void (^ButtnBlock)(NSString *name , NSString *scrName);

@end

```


.m文件

```objective-c
- (IBAction)clickReply:(id)sender {
    if (_ButtnBlock) {
  self.ButtnBlock(self.tweet.user.name ,self.tweet.user.screen_name);
    } 
}
```

Cell中的转推按钮，通过JSON中的`retweeted_status`字段来判断是否已经转推，通过STTwitter中的相关API来发送请求实现业务逻辑，关键代码如下：

转推按钮：

```objective-c
- (IBAction)clickRetweet:(id)sender {
if (self.tweet.retweeted_status) {
            
            if (self.tweet.retweeted_status.retweeted == 1) {
                self.tweet.retweeted_status.retweeted = NO;
                self.tweet.retweeted_status.retweet_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.retweet_count intValue] - 1];

                [self.account.twitter postStatusUnretweetWithID:self.tweet.retweeted_status.ID trimUser:nil successBlock:^(NSDictionary *status) {
                    
                } errorBlock:^(NSError *error) {
                }];
                [self setTweet:self.tweet];
                [self updateIconStates];
                
            } else if(self.tweet.retweeted_status.retweeted == 0){
                
                self.tweet.retweeted_status.retweeted = YES;
                self.tweet.retweeted_status.retweet_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.retweet_count intValue] + 1];
                [self.account.twitter postStatusRetweetWithID:self.tweet.retweeted_status.ID successBlock:^(NSDictionary *status) {
                    
                } errorBlock:^(NSError *error) {    
                }];
                [self setTweet:self.tweet];
                [self updateIconStates];
            }
        } else {
            
            if (self.tweet.retweeted == 1) {
                
                self.tweet.retweeted = NO;
                self.tweet.retweet_count = [NSNumber numberWithInt:[self.tweet.retweet_count intValue] - 1];
                [self.account.twitter postStatusUnretweetWithID:self.tweet.ID trimUser:nil successBlock:^(NSDictionary *status) {
                   
                } errorBlock:^(NSError *error) {    
                }];
                [self setTweet:self.tweet];
                [self updateIconStates];
            } else if(self.tweet.retweeted == 0){
                
                self.tweet.retweeted = YES;
                self.tweet.retweet_count = [NSNumber numberWithInt:[self.tweet.retweet_count intValue] + 1];
                [self.account.twitter postStatusRetweetWithID:self.tweet.ID successBlock:^(NSDictionary *status) {
                    
                } errorBlock:^(NSError *error) {   
                }];
                [self setTweet:self.tweet];
                [self updateIconStates]; 
            }
    }
}
}

```

而Cell中的收藏按钮，通过JSON中的`favorited`字段来判断是否已经收藏，一样是通过STTwitter中的相关API来发送请求实现业务逻辑，关键代码如下：

收藏按钮：

```objective-c
- (IBAction)clickFavorite:(id)sender {
    
    if (self.tweet.retweeted_status) {
        
       if (self.tweet.retweeted_status.favorited == 1) {
           
        self.tweet.retweeted_status.favorited = NO;
        self.tweet.retweeted_status.favorite_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.favorite_count intValue] - 1];
        [self.account.twitter postFavoriteDestroyWithStatusID:self.tweet.retweeted_status.ID includeEntities:nil successBlock:^(NSDictionary *status) {
           
        } errorBlock:^(NSError *error) {
            
        }];
           [self setTweet:self.tweet];
           [self updateIconStates];
           
    } else if(self.tweet.retweeted_status.favorited == 0){
        
        self.tweet.retweeted_status.favorited = YES;
        self.tweet.retweeted_status.favorite_count = [NSNumber numberWithInt:[self.tweet.retweeted_status.favorite_count intValue] + 1];
        [self.account.twitter postFavoriteCreateWithStatusID:self.tweet.retweeted_status.ID includeEntities:nil successBlock:^(NSDictionary *status) {
 
        } errorBlock:^(NSError *error) {
            
        }];
        [self setTweet:self.tweet];
        [self updateIconStates];
 }
    } else {

        if (self.tweet.favorited == 1) {
            
            self.tweet.favorited = NO;
            self.tweet.favorite_count = [NSNumber numberWithInt:[self.tweet.favorite_count intValue] - 1];
            [self.account.twitter postFavoriteDestroyWithStatusID:self.tweet.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {
                
            }];
            [self setTweet:self.tweet];
            [self updateIconStates];
            
        } else if(self.tweet.favorited == 0){

            self.tweet.favorited = YES;
            self.tweet.favorite_count = [NSNumber numberWithInt:[self.tweet.favorite_count intValue] + 1];
            [self.account.twitter postFavoriteCreateWithStatusID:self.tweet.ID includeEntities:nil successBlock:^(NSDictionary *status) {
                
            } errorBlock:^(NSError *error) {

            }];
            [self setTweet:self.tweet];
            [self updateIconStates];

        }
}

```

Cell的行高计算，在推文模型中定义了`cellHeight`属性，在Cell的set方法中实现如下代码：

```objective-c
self.tweet.cellHeight = CGRectGetMaxY(self.buttonsView.frame) + 10;

```

最后在头文件中提供一个类方法，让外界调用，代码如下：

```objective-c
+ (instancetype)tweetcellWithTableView:(UITableView *)tableView
{
    static NSString *identifier= @"tweet";
    TweetCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {

        cell=[[[NSBundle mainBundle]loadNibNamed:@"TweetCell" owner:nil options:nil] firstObject];
        //NSLog(@"创建了一个cell");
    }
    return cell;
}

```

Cell的总体思路是，通过`Xib`建立，使用`autolayout`调整控件的大小以及位置，然后通过set方法进行数据赋值，在Cell内计算好自己的高度，最后在头文件提供一个类方法给外界调用。

#### 3、Home页的下拉刷新，上拉刷新

程序一启动，直接调用Home页的`setupDownRefresh`方法，方法里面创建了一个`UIRefreshControl`控制器，通过控制器来控制用户手动下拉刷新和进入首页即刻刷新的状态，里面调用了`loadNewStatus`方法来加载推文数据，代码如下：

```objective-c
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

```

`loadNewStatus`方法的业务逻辑，取出`ID`最大的推文，通过比较`ID`大小排列推文的顺序，将`ID`大的推文放在推文数组的前面，以此类推，从大到小。通过`since_id`来获取推文的数量，代码如下：

```objective-c
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

```


上拉加载更多的推文通过`loadMoreStatus`方法实现，通过比较`max_id`，将`max_id`大的推文拼接到推文数组的后面，然后刷新`tableView`,实现代码如下：

```objective-c
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

```

#### 4、Home页的推文数据储存

数据储存采用了第三方框架`FMDB`，自定义一个储存工具类，在工具类的头文件定义两个类方法，一个用来加载缓存的推文，一个用来存储新的推文，代码如下：

.h

```objective-c
/**
 *  根据请求参数去沙盒中加载缓存的推文数据
 *
 *  @param params 请求参数
 */
+ (NSArray *)tweetsWithParams:(NSDictionary *)params;

/**
 *  存储推文数据到沙盒中
 *
 *  @param statuses 需要存储的微博数据
 */
+ (void)saveTweets:(NSArray *)tweets;

```

.m

```objective-c
static FMDatabase *_db;
+ (void)initialize
{
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"tweets.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    // 2.创表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_tweets (id integer PRIMARY KEY, tweets blob NOT NULL, idstr text NOT NULL);"];
}

+ (NSArray *)tweetsWithParams:(NSDictionary *)params
{
    // 根据请求参数生成对应的查询SQL语句
    NSString *sql = nil;
    if (params[@"since_id"]) {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_tweets WHERE idstr > %@ ORDER BY idstr DESC LIMIT 20;", params[@"since_id"]];
    } else if (params[@"max_id"]) {
        sql = [NSString stringWithFormat:@"SELECT * FROM t_tweets WHERE idstr <= %@ ORDER BY idstr DESC LIMIT 20;", params[@"max_id"]];
    } else {
        sql = @"SELECT * FROM t_tweets ORDER BY idstr DESC LIMIT 20;";
    }
    
    // 执行SQL 返回一个结果集
    FMResultSet *set = [_db executeQuery:sql];
    
    //所有的推文数据
    NSMutableArray *tweets = [NSMutableArray array];
    
    //如果 next 有值
    while (set.next) {
        
        //取出 t_tweets 表里面的 tweets(blob) 字段      代表一条推文的字典
        NSData *tweetsData = [set objectForColumnName:@"tweets"];
        
        // NSData  --> NSDictionary
        NSDictionary *tweet = [NSKeyedUnarchiver unarchiveObjectWithData:tweetsData];
        [tweets addObject:tweet];
    }
    return tweets;
}

+ (void)saveTweets:(NSArray *)tweets
{
    // 要将一个对象存进数据库的blob字段,最好先转为NSData
    // 一个对象要遵守NSCoding协议,实现协议中相应的方法,才能转成NSData
    for (NSDictionary *tweet in tweets) {
        // NSDictionary --> NSData
        NSData *tweetsData = [NSKeyedArchiver archivedDataWithRootObject:tweet];
        [_db executeUpdateWithFormat:@"INSERT INTO t_tweets(tweets, idstr) VALUES (%@, %@);", tweetsData, tweet[@"id_str"]];
    }
}


```
