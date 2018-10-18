//
//  LTAbstractDotView.h
//  MRDemo
//
//  Created by wangpeng on 2018/10/10.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTAbstractDotView : UIView

/**
 让View知道应该采用哪种状态

 @param active YES:当前是currentPage NO:当前不是currentPag
 */
- (void)changeActivityState:(BOOL)active;

@end
