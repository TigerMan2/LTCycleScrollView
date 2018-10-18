//
//  UIView+LTExtension.m
//  MRDemo
//
//  Created by wangpeng on 2018/10/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "UIView+LTExtension.h"

@implementation UIView (LTExtension)

- (CGFloat)lt_width {
    return self.frame.size.width;
}

- (void)setLt_width:(CGFloat)lt_width {
    CGRect frame = self.frame;
    frame.size.width = lt_width;
    self.frame = frame;
}

- (CGFloat)lt_height {
    return self.frame.size.height;
}

- (void)setLt_height:(CGFloat)lt_height {
    CGRect frame = self.frame;
    frame.size.height = lt_height;
    self.frame = frame;
}

- (CGFloat)lt_x {
    return self.frame.origin.x;
}

- (void)setLt_x:(CGFloat)lt_x {
    CGRect frame = self.frame;
    frame.origin.x = lt_x;
    self.frame = frame;
}

- (CGFloat)lt_y {
    return self.frame.origin.y;
}

- (void)setLt_y:(CGFloat)lt_y {
    CGRect frame = self.frame;
    frame.origin.y = lt_y;
    self.frame = frame;
}

@end
