//
//  LTViewController.m
//  LTCycleScrollView
//
//  Created by codeLuther on 10/18/2018.
//  Copyright (c) 2018 codeLuther. All rights reserved.
//

#import "LTViewController.h"
#import "LTCycleScrollView.h"
#import "UIView+LTExtension.h"

@interface LTViewController () <LTCycleScrollViewDelegate>

@end

@implementation LTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    LTCycleScrollView *scrollView = [LTCycleScrollView lt_cycleScrollViewWithFrame:CGRectMake(0, 100, self.view.lt_width, 150) imageNamesGroup:@[
                                                                                                                                                 @"http://static.guxiansheng.cn/attach/gx_adv/2018-09-17-8749503.jpg",
                                                                                                                                                 @"http://static.guxiansheng.cn/attach/gx_adv/2018-09-17-1786201.jpg",
                                                                                                                                                 @"http://static.guxiansheng.cn/attach/gx_adv/2018-09-17-9060502.jpg",
                                                                                                                                                 @"http://static.guxiansheng.cn/attach/gx_adv/2018-09-17-6937827.jpg",
                                                                                                                                                 @"http://static.guxiansheng.cn/attach/gx_adv/2018-09-17-3269096.jpeg"
                                                                                                                                                 ]];
    scrollView.delegate = self;
    scrollView.pageControlStyle = LTCycleScrollViewPageControlStyleAnimated;
    [self.view addSubview:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
