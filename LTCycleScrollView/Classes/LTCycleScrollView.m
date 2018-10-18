//
//  LTCycleScrollView.m
//  MRDemo
//
//  Created by wangpeng on 2018/10/8.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTCycleScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIView+LTExtension.h"
#import "LTCollectionViewCell.h"
#import "LTPageControl.h"

NSString * const cellID = @"LTCollectionViewCell";

#define kCycleScrollViewInitialPageControlDotSize CGSizeMake(10, 10)

@interface LTCycleScrollView ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *mainView;
@property (nonatomic, weak) UICollectionViewFlowLayout *layout;
@property (nonatomic, weak) UIControl *pageControl;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, strong) NSArray *imagePathsGroup;
@property (nonatomic, assign) NSInteger totalItemCount;
@end

@implementation LTCycleScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
        [self setupMainView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
    [self setupMainView];
}

- (void)initialization {
    _autoScrollTimerInterval = 2.0;
    _autoScroll = YES;
    _hidesForSinglePage = YES;
    _pageControlDotSize = kCycleScrollViewInitialPageControlDotSize;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _showPageControl = YES;
    _isfinishLoop = YES;
    _pageControlStyle = LTCycleScrollViewPageControlStyleDefault;
    
    self.backgroundColor = [UIColor lightGrayColor];
}

- (void)setupMainView {
    //UICollectionViewFlowLayout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _layout = layout;
    
    //UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    [collectionView registerClass:[LTCollectionViewCell class] forCellWithReuseIdentifier:cellID];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    _mainView = collectionView;
    
    [self addSubview:collectionView];
    
}

+ (instancetype)lt_cycleScrollViewWithFrame:(CGRect)frame imageNamesGroup:(NSArray *)imageNamesGroup {
    LTCycleScrollView *scrollView = [[LTCycleScrollView alloc] initWithFrame:frame];
    scrollView.localImageNamesGroup = [NSMutableArray arrayWithArray:imageNamesGroup];
    return scrollView;
}

+ (instancetype)lt_cycleScrollViewWithFrame:(CGRect)frame shouldIsfinishLoop:(BOOL)isfinishLoop imageNamesGroup:(NSArray *)imageNamesGroup {
    LTCycleScrollView *scrollView = [[LTCycleScrollView alloc] initWithFrame:frame];
    scrollView.isfinishLoop = isfinishLoop;
    scrollView.localImageNamesGroup = [NSMutableArray arrayWithArray:imageNamesGroup];
    return scrollView;
}

+ (instancetype)lt_cycleScrollViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLsGroup {
    LTCycleScrollView *scrollView = [[LTCycleScrollView alloc] initWithFrame:frame];
    scrollView.imageURLStringsGroup = [NSMutableArray arrayWithArray:imageURLsGroup];
    return scrollView;
}

#pragma mark -----setter------
- (void)setLocalImageNamesGroup:(NSArray *)localImageNamesGroup {
    _localImageNamesGroup = localImageNamesGroup;
    self.imagePathsGroup = [localImageNamesGroup copy];
}

- (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup {
    _imageURLStringsGroup = imageURLStringsGroup;
    
    NSMutableArray *temp = [NSMutableArray new];
    [_imageURLStringsGroup enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *urlString;
        if ([obj isKindOfClass:[NSString class]]) {
            urlString = obj;
        } else if ([obj isKindOfClass:[NSURL class]]) {
            NSURL *url = (NSURL *)obj;
            urlString = url.absoluteString;
        }
        if (urlString) {
            [temp addObject:urlString];
        }
    }];
    self.imagePathsGroup = [temp copy];
}

- (void)setImagePathsGroup:(NSArray *)imagePathsGroup {
    [self invalidateTimer];
    
    _imagePathsGroup = imagePathsGroup;
    
    _totalItemCount = self.isfinishLoop ? imagePathsGroup.count * 100 : imagePathsGroup.count;
    
    if (imagePathsGroup.count > 1) { //图片多于1张的时候，才支持滑动
        self.mainView.scrollEnabled = YES;
        [self setAutoScroll:self.autoScroll];
    } else {
        self.mainView.scrollEnabled = NO;
        [self setAutoScroll:NO];
    }
    
    //设置UIPageControl
    [self setupControl];
    //刷新collection
    [self.mainView reloadData];
}

- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    
    self.pageControl.hidden = !showPageControl;
}

#pragma mark -----UIPageControl------
- (void)setupControl {
    if (_pageControl) {
        //如果存在PageControl,则先移除
        [_pageControl removeFromSuperview];
    }
    
    //没有图片不显示pageControl
    if (self.imagePathsGroup.count == 0) return;
    
    //图片为单张时，是否隐藏pageControl
    if ((self.imagePathsGroup.count == 1) && self.hidesForSinglePage) return;
    
    NSInteger indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:[self currentIndex]];
    
    switch (self.pageControlStyle) {
        case LTCycleScrollViewPageControlStyleDefault:
        {
            //UIPageControl
            UIPageControl *pageControl = [[UIPageControl alloc] init];
            pageControl.numberOfPages = self.imagePathsGroup.count;
            pageControl.currentPage = indexOnPageControl;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPageIndicatorTintColor = self.currentPageDotColor;
            pageControl.pageIndicatorTintColor = self.pageDotColor;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
        case LTCycleScrollViewPageControlStyleAnimated:
        {
            LTPageControl *pageControl = [[LTPageControl alloc] init];
            pageControl.numOfPages = self.imagePathsGroup.count;
            pageControl.dotColor = self.currentPageDotColor;
            pageControl.userInteractionEnabled = NO;
            pageControl.currentPage = indexOnPageControl;
            [self addSubview:pageControl];
            _pageControl = pageControl;
        }
            break;
            
        default:
            break;
    }
    
    // ------重设分页控件的DotImage
    if (self.currentPageDotImage) {
        self.currentPageDotImage = self.currentPageDotImage;
    }
    
    if (self.pageDotImage) {
        self.pageDotImage = self.pageDotImage;
    }
}

- (void)setCurrentPageDotImage:(UIImage *)currentPageDotImage {
    _currentPageDotImage = currentPageDotImage;
    if (self.pageControlStyle != LTCycleScrollViewPageControlStyleAnimated) {
        self.pageControlStyle = LTCycleScrollViewPageControlStyleAnimated;
    }
    [self setCustomPageControlDotImage:currentPageDotImage isCurrentDot:YES];
}

- (void)setPageDotImage:(UIImage *)pageDotImage {
    _pageDotImage = pageDotImage;
    if (self.pageControlStyle != LTCycleScrollViewPageControlStyleAnimated) {
        self.pageControlStyle = LTCycleScrollViewPageControlStyleAnimated;
    }
    [self setCustomPageControlDotImage:pageDotImage isCurrentDot:NO];
}

- (void)setCustomPageControlDotImage:(UIImage *)image isCurrentDot:(BOOL)isCurrentDot {
    if (!image || !self.pageControl) return;
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)_pageControl;
        if (isCurrentDot) {
            pageControl.currentDotImage = image;
        } else {
            pageControl.dotImage = image;
        }
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    
    _layout.scrollDirection = scrollDirection;
}

- (void)setIsfinishLoop:(BOOL)isfinishLoop {
    _isfinishLoop = isfinishLoop;
    
    if (self.imagePathsGroup.count) {
        self.imagePathsGroup = self.imagePathsGroup;
    }
}

- (void)setPageControlStyle:(LTCycleScrollViewPageControlStyle)pageControlStyle
{
    _pageControlStyle = pageControlStyle;
    
    [self setupControl];
}

- (void)setPageDotColor:(UIColor *)pageDotColor {
    _pageDotColor = pageDotColor;
    
    if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.pageIndicatorTintColor = pageDotColor;
    }
}

- (void)setCurrentPageDotColor:(UIColor *)currentPageDotColor {
    _currentPageDotColor = currentPageDotColor;
    
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)_pageControl;
        pageControl.dotColor = currentPageDotColor;
    } else if ([self.pageControl isKindOfClass:[UIPageControl class]]) {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPageIndicatorTintColor = currentPageDotColor;
    }
}

#pragma mark -----Timer------
- (void)setupTimer {
    [self invalidateTimer];//开启定时器前，先暂停之前的定时器
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimerInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll {
    if (0 == _totalItemCount) return;
    
    NSInteger currentIndex = [self currentIndex];
    NSInteger targetIndex = currentIndex + 1;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(NSInteger)index {
    if (index >= _totalItemCount) {
        if (self.isfinishLoop) {
            index = _totalItemCount * 0.5;
            [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        }
        return;
    }
    [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (NSInteger)currentIndex {
    if (_mainView.lt_width == 0 || _mainView.lt_height == 0) {
        return 0;
    }
    
    NSInteger index = 0;
    if (_layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (_mainView.contentOffset.x + _layout.itemSize.width * 0.5) / _layout.itemSize.width;
    } else {
        index = (_mainView.contentOffset.y + _layout.itemSize.height * 0.5) / _layout.itemSize.height;
    }
    
    return MAX(0, index);
}

- (NSInteger)pageControlIndexWithCurrentCellIndex:(NSInteger)index {
    return (NSInteger)index % self.imagePathsGroup.count;
}

#pragma mark -----UICollectionViewDataSource------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _totalItemCount;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LTCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.item];
    
    NSString *imagePath = self.imagePathsGroup[itemIndex];
    if ([imagePath isKindOfClass:[NSString class]]) {
        if ([imagePath hasPrefix:@"http"]) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:imagePath]];
        } else {
            UIImage *image = [UIImage imageNamed:imagePath];
            if (!image) {
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            cell.imageView.image = image;
        }
    } else if ([imagePath isKindOfClass:[UIImage class]]) {
        cell.imageView.image = (UIImage *)imagePath;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lt_cycleScrollView:didSelectedItemAtIndex:)]) {
        [self.delegate lt_cycleScrollView:self didSelectedItemAtIndex:[self pageControlIndexWithCurrentCellIndex:indexPath.item]];
    } else if (self.clickItemOperationBlock) {
        self.clickItemOperationBlock(indexPath.item);
    }
}

#pragma mark -----UIScrollViewDelegate------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.imagePathsGroup.count) return;
    
    NSInteger itemIndex = [self currentIndex];
    NSInteger indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    } else {
        UIPageControl *pageControl = (UIPageControl *)_pageControl;
        pageControl.currentPage = indexOnPageControl;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:_mainView];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!self.imagePathsGroup.count) return;
    
    NSInteger itemIndex = [self currentIndex];
    NSInteger indexOnPageControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    if (self.delegate && [self.delegate respondsToSelector:@selector(lt_cycleScrollView:didScrollToIndex:)]) {
        [self.delegate lt_cycleScrollView:self didScrollToIndex:indexOnPageControl];
    } else if (self.itemDidScrollOperationBlock) {
        self.itemDidScrollOperationBlock(indexOnPageControl);
    }
    
}

#pragma mark -----layoutSubView------
- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    _layout.itemSize = self.frame.size;
    
    _mainView.frame = self.bounds;
    if (_mainView.contentOffset.x == 0 && _totalItemCount) {
        NSInteger targetIndex = 0;
        if (self.isfinishLoop) {
            targetIndex = _totalItemCount * 0.5;
        } else {
            targetIndex = 0;
        }
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    CGSize size = CGSizeZero;
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)_pageControl;
        if (!(self.pageDotImage && self.currentPageDotImage && CGSizeEqualToSize(kCycleScrollViewInitialPageControlDotSize, self.pageControlDotSize))) {
            pageControl.dotSize = self.pageControlDotSize;
        }
        size = [pageControl sizeForNumberOfPages:self.imagePathsGroup.count];
    } else {
        size = CGSizeMake(self.imagePathsGroup.count * self.pageControlDotSize.width * 1.5, self.pageControlDotSize.height);
    }
    CGFloat x = (self.lt_width - size.width) * 0.5;
    CGFloat y = self.lt_height - size.height - 10;
    
    if ([self.pageControl isKindOfClass:[LTPageControl class]]) {
        LTPageControl *pageControl = (LTPageControl *)_pageControl;
        [pageControl sizeToFit];
    }
    
    CGRect pageFrame = CGRectMake(x, y, size.width, size.height);
    self.pageControl.frame = pageFrame;
    self.pageControl.hidden = !_showPageControl;
}

// ------解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

// ------解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    _mainView.delegate = nil;
    _mainView.dataSource = nil;
}


#pragma mark - public actions

- (void)adjustWhenControllerViewWillAppera
{
    long targetIndex = [self currentIndex];
    if (targetIndex < _totalItemCount) {
        [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
}

@end
