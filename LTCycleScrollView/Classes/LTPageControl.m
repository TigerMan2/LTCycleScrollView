//
//  LTPageControl.m
//  MRDemo
//
//  Created by wangpeng on 2018/10/10.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTPageControl.h"
#import "LTAnimatedDotView.h"

@interface LTPageControl ()

@property (nonatomic, strong) NSMutableArray *dots;

@end

@implementation LTPageControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization {
    self.dotViewClass = [LTAnimatedDotView class];
    self.spacingBetweenDot = 8;
    self.dotSize = CGSizeMake(8, 8);
    self.numOfPages = 0;
    self.currentPage = 0;
    self.hidesForSinglePage = NO;
    self.shouldResizeFromCenter = YES;
}

#pragma mark -----Touch event------
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (touch.view != self) {
        NSInteger index = [self.dots indexOfObject:touch.view];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ltPageControl:didSelectPageIndex:)]) {
            [self.delegate ltPageControl:self didSelectPageIndex:index];
        }
    }
}
#pragma mark -----Layout------
- (void)sizeToFit {
    [self updateFrame:YES];
}

- (void)updateFrame:(BOOL)overrideExistingFrame {
    CGPoint center = self.center;
    CGSize requestSize = [self sizeForNumberOfPages:self.numOfPages];
    
    if (overrideExistingFrame || ((CGRectGetWidth(self.frame) < requestSize.width || CGRectGetHeight(self.frame) < requestSize.height) && !overrideExistingFrame)) {
        self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), requestSize.width, requestSize.height);
        if (self.shouldResizeFromCenter) {
            self.center = center;
        }
    }
    
    [self resetDotViews];
}

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount {
    return CGSizeMake((self.dotSize.width + self.spacingBetweenDot) * pageCount - self.spacingBetweenDot, self.dotSize.height);
}

- (void)updateDots {
    if (self.numOfPages == 0) return;
    
    for (NSInteger i = 0; i < self.numOfPages; i++) {
        UIView *dot;
        if (self.dots.count > i) {
            dot = self.dots[i];
        } else {
            dot = [self generateDotView];
        }
        
        [self updateDotFrame:dot atIndex:i];
    }
    
    [self changeActivity:YES atIndex:self.currentPage];
    
    [self hideForSinglePage];
}

- (void)changeActivity:(BOOL)active atIndex:(NSInteger)index {
    
    if (self.dotViewClass) {
        LTAbstractDotView *dotView = (LTAbstractDotView *)[self.dots objectAtIndex:index];
        if ([dotView respondsToSelector:@selector(changeActivityState:)]) {
            [dotView changeActivityState:active];
        } else {
            NSLog(@"Custom view : %@ must implement an 'changeActivityState' method or you can subclass %@ to help you.", self.dotViewClass, [LTAbstractDotView class]);
        }
    } else if (self.dotImage && self.currentDotImage) {
        UIImageView *dotView = (UIImageView *)[self.dots objectAtIndex:index];
        dotView.image = (active) ? self.currentDotImage : self.dotImage;
    }
}

- (void)resetDotViews {
    for (UIView *dot in self.dots) {
        [dot removeFromSuperview];
    }
    [self.dots removeAllObjects];
    [self updateDots];
}

/**
 Update the frame of a specific dot at a specific index

 @param dot Dot View
 @param index Page index of dot
 */
- (void)updateDotFrame:(UIView *)dot atIndex:(NSInteger)index {
    CGFloat x = (self.dotSize.width + self.spacingBetweenDot) * index + ((CGRectGetWidth(self.frame) - [self sizeForNumberOfPages:self.numOfPages].width)/2);
    CGFloat y = (CGRectGetHeight(self.frame) - self.dotSize.height) / 2;
    dot.frame = CGRectMake(x, y, self.dotSize.width, self.dotSize.height);
}

#pragma mark -----Until------

- (UIView *)generateDotView {
    UIView *dotView;
    if (self.dotViewClass) {
        dotView = [[self.dotViewClass alloc] initWithFrame:CGRectMake(0, 0, self.dotSize.width, self.dotSize.height)];
        if ([dotView isKindOfClass:[LTAnimatedDotView class]] && self.dotColor) {
            ((LTAnimatedDotView *)dotView).dotColor = self.dotColor;
        }
    } else {
        dotView = [[UIImageView alloc] initWithImage:self.dotImage];
        dotView.frame = CGRectMake(0, 0, self.dotSize.width, self.dotSize.height);
    }
    
    if (dotView) {
        [self addSubview:dotView];
        [self.dots addObject:dotView];
    }
    dotView.userInteractionEnabled = YES;
    return dotView;
}

#pragma mark -----Setter------

- (void)setNumOfPages:(NSInteger)numOfPages {
    _numOfPages = numOfPages;
    // ------reset view
    [self resetDotViews];
}


- (void)setSpacingBetweenDot:(CGFloat)spacingBetweenDot {
    _spacingBetweenDot = spacingBetweenDot;
    // ------reset view
    [self resetDotViews];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    
    if (self.numOfPages == 0 || currentPage == _currentPage) {
        _currentPage = currentPage;
        return;
    }
    // ------将之前currentPage设置为page
    [self changeActivity:NO atIndex:_currentPage];
    
    _currentPage = currentPage;
    
    // ------设置新的currentPage
    [self changeActivity:YES atIndex:_currentPage];
}

- (void)setDotImage:(UIImage *)dotImage {
    _dotImage = dotImage;
    [self resetDotViews];
    self.dotViewClass = nil;
}

- (void)setCurrentDotImage:(UIImage *)currentDotImage {
    _currentDotImage = currentDotImage;
    [self resetDotViews];
    self.dotViewClass = nil;
}

- (void)setDotViewClass:(Class)dotViewClass {
    _dotViewClass = dotViewClass;
    self.dotSize = CGSizeZero;
    [self resetDotViews];
    
}

#pragma mark -----getter------

- (NSMutableArray *)dots {
    if (!_dots) {
        _dots = [[NSMutableArray alloc] init];
    }
    return _dots;
}

- (void)hideForSinglePage {
    if (self.hidesForSinglePage && self.dots.count == 1) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}

@end
