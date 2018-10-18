//
//  LTCycleScrollView.h
//  MRDemo
//
//  Created by wangpeng on 2018/10/8.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LTCycleScrollViewPageControlStyleDefault,   // 系统自带经典样式
    LTCycleScrollViewPageControlStyleAnimated,  // 动画效果
    LTCycleScrollViewPageControlStyleNone,      // 不显示
} LTCycleScrollViewPageControlStyle;

@class LTCycleScrollView;

@protocol LTCycleScrollViewDelegate <NSObject>

@optional

- (void)lt_cycleScrollView:(LTCycleScrollView *)cycleScrollView didSelectedItemAtIndex:(NSInteger)index;

- (void)lt_cycleScrollView:(LTCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index;

@end

@interface LTCycleScrollView : UIView

/**
 *  自动滚动的时间间隔，默认是2s
 */
@property (nonatomic, assign) NSTimeInterval autoScrollTimerInterval;

/**
 *  是否自动滚动，默认是YES
 */
@property (nonatomic, assign) BOOL autoScroll;

/**
 *  本地图片数组
 */
@property (nonatomic, strong) NSArray *localImageNamesGroup;

/**
 *  网络图片数组
 */
@property (nonatomic, strong) NSArray *imageURLStringsGroup;

/**
 *  当只有一张图片是，是否隐藏分页控件， 默认是YES
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/**
 *  当前分页控件小圆点颜色
 */
@property (nonatomic, strong) UIColor *currentPageDotColor;

/**
 *  分页控件小圆点颜色
 */
@property (nonatomic, strong) UIColor *pageDotColor;

/**
 *  分页控件小圆点大小
 */
@property (nonatomic, assign) CGSize pageControlDotSize;

/**
 *  是否显示分页控件，默认是显示
 */
@property (nonatomic, assign) BOOL showPageControl;

/**
 *  当前分页控件的图片
 */
@property (nonatomic, strong) UIImage * currentPageDotImage;

/**
 *  分页控件的图片
 */
@property (nonatomic, strong) UIImage * pageDotImage;

/**
 *  图片滚动方向，默认是水平方向
 */
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/**
 *  是否无限滚动，默认是YES
 */
@property (nonatomic, assign) BOOL isfinishLoop;

/**
 *  PageControl的显示样式，默认是经典样式
 */
@property (nonatomic, assign) LTCycleScrollViewPageControlStyle pageControlStyle;

/**
 *  Delegate
 */
@property (nonatomic, weak) id <LTCycleScrollViewDelegate> delegate;

/**
 *  Block方式监听点击
 */
@property (nonatomic, copy) void (^clickItemOperationBlock)(NSInteger index);

/**
 *  Block方式监听滚动
 */
@property (nonatomic, copy) void (^itemDidScrollOperationBlock)(NSInteger index);

/**
 *  初始化轮播图---本地
 */
+ (instancetype)lt_cycleScrollViewWithFrame:(CGRect)frame imageNamesGroup:(NSArray *)imageNamesGroup;

/**
 *  解决viewWillAppear时出现时轮播图卡在一半的问题，在控制器viewWillAppear时调用此方法
 */
- (void)adjustWhenControllerViewWillAppera;


@end
