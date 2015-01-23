# YQZCycleScrollView
循环滚动图片

# 使用方法

1、定义YQZCycleScrollViewDelegate <YQZCycleScrollViewDelegate>

2、定义滚动图片数组
/*!
 @brief     存储轮换列表数据
 */
@property (nonatomic, strong) NSMutableArray *marqueeImageArray;

在viewDidLoad中添加初始化

    self.marqueeImageArray = [NSMutableArray array];

    for (NSInteger i=0; i<[datas count]; i++) {
        NSDictionary *dict = [datas objectAtIndex:i];
        YQZImageADModel *model = [[YQZImageADModel alloc] init];
        model.modelID = [[dict objectForKey:@"id"] integerValue];
        model.beginDate = [dict objectForKey:@"beginDate"];
        model.endDate = [dict objectForKey:@"endDate"];
        model.title = [dict objectForKey:@"title"];
        model.position = [[dict objectForKey:@"position"] integerValue];
        model.desc = [dict objectForKey:@"desc"];
        NSString *imageURLString = [NSString stringWithFormat:@"%@", [dict valueForKey:@"image"]];
        model.imageUrl = imageURLString;
        model.url = [dict objectForKey:@"url"];
        [self.marqueeImageArray addObject:model];
    }

3、加载轮换图片列表控件
    self.cycleScrollView = [[YQZCycleScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.f, 134)
                                                    withImageArray:self.marqueeImageArray];
    self.cycleScrollView.cycleScrollViewDelegate = self;    
    self.contentTableView.tableHeaderView = self.cycleScrollView;

4、实现代理函数

//广告图片点击
- (void)cycleScrollViewDidClick:(YQZCycleScrollView *)cycleScrollView withIndex:(int)index
{
    if (([self.marqueeImageArray count] == 0)||(index > [self.marqueeImageArray count]))
    {
        return;
    }
    
    YQZImageADModel *imageADModel = [self.marqueeImageArray objectAtIndex:index];
    //todo点击处理
}
