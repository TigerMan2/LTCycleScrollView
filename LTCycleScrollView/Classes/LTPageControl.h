//
//  LTPageControl.h
//  MRDemo
//
//  Created by wangpeng on 2018/10/10.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTPageControlDelegate;

@interface LTPageControl : UIControl

/**
 *  自定义的View,必须继承LTAbstractDotView
 */
@property (nonatomic, assign) Class dotViewClass;

/**
 *  Dot Color
 */
@property (nonatomic, strong) UIColor *dotColor;

/**
 *  Page dotImage
 */
@property (nonatomic, strong) UIImage *dotImage;

/**
 *  Current page dotImage
 */
@property (nonatomic, strong) UIImage *currentDotImage;

/**
 *  Dot size
 */
@property (nonatomic, assign) CGSize dotSize;

/**
 *  Spacing between two dot views. Default is 8.
 */
@property (nonatomic, assign) CGFloat spacingBetweenDot;

/**
 *  Number of page for control, Default is 0
 */
@property (nonatomic, assign) NSInteger numOfPages;

/**
 *  Current page on which control is active, Default is 0
 */
@property (nonatomic, assign) NSInteger currentPage;

/**
 *  Hide the control if only one page. Default is NO
 */
@property (nonatomic, assign) BOOL hidesForSinglePage;

/**
 *  Let the control know if should grow bigger by keeping center, or just get longer (right side expanding). By default YES
 */
@property (nonatomic, assign) BOOL shouldResizeFromCenter;

@property (nonatomic, weak) id <LTPageControlDelegate> delegate;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount;

@end

@protocol LTPageControlDelegate <NSObject>

@optional
- (void)ltPageControl:(LTPageControl *)pageControl didSelectPageIndex:(NSInteger)pageIndex;

@end
