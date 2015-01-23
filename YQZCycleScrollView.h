//
//  YQZCycleScrollView.h
//
//  Created by mahailin on 13-7-19.
//  Copyright (c) 2013年 mahailin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YQZCycleScrollView;

/*!
 @brief CycleScrollView的回调协议
 */
@protocol YQZCycleScrollViewDelegate <NSObject>

@optional

/*!
 @brief     点击某张图片的回调方法
 @param     cycleScrollView CycleScrollView类的实例
 @param     index 所点图片的下标
 @return    void
 */
- (void)cycleScrollViewDidClick:(YQZCycleScrollView *)cycleScrollView withIndex:(int)index;

@end

/*!
 @brief 可以循环滚动图片的scrollView
 */
@interface YQZCycleScrollView : UIView

/*!
 @brief     delegate
 */
@property (nonatomic, assign) id<YQZCycleScrollViewDelegate> cycleScrollViewDelegate;

/*!
 @brief     类的实例化方法
 @param     frame 视图的frame
 @param     imageArray 图片URL地址数组
 @return    返回该类的实例
 */
- (id)initWithFrame:(CGRect)frame withImageArray:(NSMutableArray *)imageArray;

/*!
 @brief   刷新界面
 @param   imageArray 图片URL地址数组
 @return  void
 */
- (void)reloadCycleScrollView:(NSMutableArray *)imageArray;

/*!
 @brief 初始化定时器
 */
- (void)startTimer;

/*!
 @brief 停止定时器
 */
- (void)stopTimer;

@end
