//
//  LTCollectionViewCell.m
//  MRDemo
//
//  Created by wangpeng on 2018/10/9.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTCollectionViewCell.h"

@implementation LTCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupImageView];
    }
    return self;
}

- (void)setupImageView {
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self.contentView addSubview:imageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _imageView.frame = self.bounds;
}

@end
