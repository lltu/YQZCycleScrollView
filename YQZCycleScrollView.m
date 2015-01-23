//
//  YQZCycleScrollView.m
//
//  Created by mahailin on 13-7-19.
//  Copyright (c) 2013年 mahailin. All rights reserved.
//

#import "YQZCycleScrollView.h"
#import "UIImageView+AFNetworking.h"

/*!
 @brief 轮换图片的时间
 */
#define kTimerCount 5

/*!
 @brief 该控件一次性最多显示的图片数量
 */
#define kShowImageCount 3

/*!
 @brief 图片的标记
 */
#define kImageViewTag 10000

@interface YQZCycleScrollView ()<UIScrollViewDelegate>

/*!
 @brief     scrollView
 */
@property (nonatomic, retain) UIScrollView *imageScrollView;

/**
 *  PageControl
 */
@property (nonatomic, strong) UIPageControl *pageControl;

/*!
 @brief     存储图片的数组
 */
@property (nonatomic, retain) NSMutableArray *imageMutableArray;

/*!
 @brief     图片的总数量
 */
@property (nonatomic, assign) int imageCount;

/*!
 @brief     图片的大小
 */
@property (nonatomic, assign) CGSize imageSize;

/*!
 @brief     当前页的下标
 */
@property (nonatomic, assign) int currentPageIndex;

/*!
 @brief     定时器
 */
@property (nonatomic, retain) NSTimer *imageTimer;

@end

@implementation YQZCycleScrollView

/*!
 @brief 初始化scrollview
 */
- (UIScrollView *)imageScrollView
{
    if (!_imageScrollView)
    {
        _imageScrollView = [[UIScrollView alloc] initWithFrame:
                            CGRectMake(0.0, 0.0, self.imageSize.width, self.imageSize.height)];
        
        _imageScrollView.bounces = NO;
        _imageScrollView.delegate = self;
        _imageScrollView.pagingEnabled = YES;
        _imageScrollView.showsHorizontalScrollIndicator = NO;
        _imageScrollView.showsVerticalScrollIndicator = NO;
        _imageScrollView.contentSize = CGSizeMake(self.imageSize.width * self.imageCount, self.imageSize.height);
    }
    
    return _imageScrollView;
}

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0,kdViewHeight - 20, kdViewWidth, 20)];
        if (kdSystemVersion >= 6.f)
        {
            _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
            _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];            
//            [_pageControl addTarget:self action:@selector(pageChange) forControlEvents:UIControlEventValueChanged];
        }
    }
    _pageControl.numberOfPages = ((self.imageCount - 2) > 0 ? (self.imageCount - 2) : 0);
    return _pageControl;
}

/*!
 @brief     类的实例化方法
 @param     frame 视图的frame
 @param     imageArray 图片URL地址数组
 @return    返回该类的实例
 */
- (id)initWithFrame:(CGRect)frame withImageArray:(NSMutableArray *)imageArray
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self initViewWithImageArray:imageArray];
    }
    
    return self;
}

/*!
 @brief   刷新界面
 @param   imageArray 图片URL地址数组
 @return  void
 */
- (void)reloadCycleScrollView:(NSMutableArray *)imageArray
{
    [self stopTimer];
    
    //清除界面
    for (id cycleSubView in self.subviews)
    {
        if ([cycleSubView isKindOfClass:[UIScrollView class]])
        {
            for (id imageSubView in [(UIScrollView *)cycleSubView subviews])
            {
                [(UIView *)imageSubView removeFromSuperview];
            }
        }
        
        [(UIView *)cycleSubView removeFromSuperview];
        
        if ([cycleSubView isKindOfClass:[UIScrollView class]])
        {
            self.imageScrollView = nil;
        }
    }
    
    //重新生成界面
    [self.imageMutableArray removeAllObjects];
    [self initViewWithImageArray:imageArray];
}

/*!
 @brief 初始化界面
 */
- (void)initViewWithImageArray:(NSMutableArray *)imageArray
{
    //生成供循环滚动图片的数组
    if ([imageArray count] > 0)//若图片大于0生成图片数组
    {
        self.imageMutableArray = [NSMutableArray array];
        
        for (NSURL *urlStringURL in imageArray)
        {
            [self.imageMutableArray addObject:urlStringURL];
        }
        
        [self.imageMutableArray insertObject:[imageArray objectAtIndex:[imageArray count] - 1] atIndex:0];
        [self.imageMutableArray addObject:[imageArray objectAtIndex:0]];
    }
    
    self.imageSize = self.frame.size;
    self.imageCount = [self.imageMutableArray count];
    
    //加载imageScrollView
    [self addSubview:self.imageScrollView];
    
    //加载pageControl
    [self addSubview:self.pageControl];
    
    //处理当传递过来的数据为空时界面的显示问题
    if ([imageArray count] < 1)
    {
        UIImageView *cycleImageView = [[UIImageView alloc] initWithFrame:
                                        CGRectMake(0.0, 0.0, self.imageSize.width, self.imageSize.height)];
        
        UIImage *cycleImage = [UIImage imageNamed:@"addefault.png"];
        cycleImageView.image = cycleImage;
        
        [self addSubview:cycleImageView];
    }
    
    //生成图片
    for (int i = 0; i < self.imageCount; i++)
    {
        UIImageView *cycleImageView = [[UIImageView alloc] initWithFrame:
              CGRectMake(self.imageSize.width * i, 0.0, self.imageSize.width, self.imageSize.height)];
        
        cycleImageView.exclusiveTouch = YES;
        
        if (i < 3)
        {
            [cycleImageView setImageWithURL:[self.imageMutableArray objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"addefault.png"]];
        }
        else
        {
            UIImage *cycleImage = [UIImage imageNamed:@"addefault.png"];
            cycleImageView.image = cycleImage;
        }
        
        cycleImageView.userInteractionEnabled = YES;
        cycleImageView.tag = kImageViewTag + i;
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                action:@selector(cycleImageViewTaped:)];
        [cycleImageView addGestureRecognizer:tapGestureRecognizer];
        [self.imageScrollView addSubview:cycleImageView];
    }
    
    //设置到第一张图片的位置以及创建分段控件
    if ([imageArray count] > 0)
    {
        [self.imageScrollView setContentOffset:CGPointMake(self.imageSize.width, 0)];
        
        if (self.imageCount == 3)//相当于只有一张图，此时不让imageScrollView可以滚动
        {
            self.imageScrollView.scrollEnabled = NO;
        }
        else
        {
            self.imageScrollView.scrollEnabled = YES;
            
            //初始化定时器
            [self startTimer];
        }
    }
}


/*!
 @brief 初始化定时器
 */
- (void)startTimer
{
    [self stopTimer];
    
    if (self.imageCount < 4)//相当于只有一张图，此时不让imageScrollView可以滚动
        return;
    
    self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerCount
                                                       target:self
                                                     selector:@selector(imageTimerChange)
                                                     userInfo:nil
                                                      repeats:YES];
}

/*!
 @brief 定时器的回调方法
 */
- (void)imageTimerChange
{
    [self.imageScrollView setContentOffset:CGPointMake((self.currentPageIndex + 1) * self.imageSize.width, 0)
                                  animated:YES];
    
    //若是已经滚动到最后一张图则重置回第一张图所在的位置
    if (self.currentPageIndex + 1 == self.imageCount - 1)
    {
        [self performSelector:@selector(resetScrollViewContetOffset) withObject:nil afterDelay:0.4];
    }
}

/*!
 @brief 重设scrollview到第一页
 */
- (void)resetScrollViewContetOffset
{
    [self.imageScrollView setContentOffset:CGPointMake(self.imageSize.width, 0)];
}

/*!
 @brief 加载要显示在界面上的三张图片
 */
- (void)loadShowImage:(int)currentShowPageIndex
{
    for (int i = 0; i < self.imageCount; i++)
    {
        UIImageView *cycleImageView = (UIImageView *)[self.imageScrollView viewWithTag:kImageViewTag + i];
        
        if (i == currentShowPageIndex - 1
            || i == currentShowPageIndex
            || i == (currentShowPageIndex + 1) % self.imageCount)
        {
            [cycleImageView setImageWithURL:[self.imageMutableArray objectAtIndex:i] placeholderImage:[UIImage imageNamed:@"addefault.png"]];
        }
        else
        {
            UIImage *cycleImage = [UIImage imageNamed:@"addefault.png"];
            cycleImageView.image = cycleImage;
        }
    }
}

/*!
 @brief 停止定时器
 */
- (void)stopTimer
{
    if (self.imageTimer)
    {
        if ([self.imageTimer isValid])
        {
            [self.imageTimer invalidate];
            self.imageTimer = nil;
        }
    }
}

/*!
 @brief 图片的点击手势方法
 */
- (void)cycleImageViewTaped:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.cycleScrollViewDelegate
        && [self.cycleScrollViewDelegate respondsToSelector:@selector(cycleScrollViewDidClick:withIndex:)])
    {
        int clickIndex = tapGestureRecognizer.view.tag - kImageViewTag;
        
        if (clickIndex == self.imageCount - 1)
        {
            clickIndex = 0;
        }
        else if (clickIndex == 0)
        {
            clickIndex = self.imageCount - 2;
        }
        else
        {
            clickIndex = clickIndex - 1;
        }
        
        [self.cycleScrollViewDelegate cycleScrollViewDidClick:self withIndex:clickIndex];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [self stopTimer];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int pageIndex = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (pageIndex != self.currentPageIndex)
    {
        self.currentPageIndex = pageIndex;
        
        //页面一变立即加载新的三张image
        [self loadShowImage:self.currentPageIndex % self.imageCount];
        self.pageControl.currentPage = (self.currentPageIndex - 1);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.currentPageIndex == 0)
    {
        [scrollView setContentOffset:CGPointMake(self.imageSize.width * (self.imageCount - 2), 0)];
    }
    else if (self.currentPageIndex == self.imageCount - 1)
    {
        [self.imageScrollView setContentOffset:CGPointMake(self.imageSize.width, 0)];
    }
    
    [self startTimer];
}

@end
