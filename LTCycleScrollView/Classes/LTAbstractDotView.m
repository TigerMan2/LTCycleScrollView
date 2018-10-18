//
//  LTAbstractDotView.m
//  MRDemo
//
//  Created by wangpeng on 2018/10/10.
//  Copyright © 2018 mrstock. All rights reserved.
//

#import "LTAbstractDotView.h"

@implementation LTAbstractDotView

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"you must override %@ in %@",NSStringFromSelector(_cmd),self.class]
                                 userInfo:nil];
}

- (void)changeActivityState:(BOOL)active {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"you must override %@ in %@",NSStringFromSelector(_cmd),self.class]
                                 userInfo:nil];
}

@end
