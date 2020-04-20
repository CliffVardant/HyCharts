//
//  HyChartBarLayer.m
//  HyChartsDemo
//
//  Created by Hy on 2018/3/23.
//  Copyright © 2018 Hy. All rights reserved.
//

#import "HyChartBarLayer.h"
#import "HyChartModel.h"
#import "HyChartBarConfigure.h"


@interface HyChartBarLayer () <CAAnimationDelegate>
@property (nonatomic,strong) NSArray<CAShapeLayer *> *layers;
@end


@implementation HyChartBarLayer

- (void)setNeedsRendering {
    [super setNeedsRendering];

    if (!self.dataSource.modelDataSource.visibleModels.count) {
        return;
    }
    
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat width = self.dataSource.configreDataSource.configure.scaleWidth;
    double maxValue = self.dataSource.axisDataSource.yAxisModel.yAxisMaxValue.doubleValue;
    CGFloat heightRate = height / maxValue;
    CGFloat oneBarWidth = width / self.layers.count;
    
    NSMutableArray<UIBezierPath *> *paths = @[].mutableCopy;
    for (NSInteger i = 0; i < self.layers.count; i++) {
        [paths addObject:UIBezierPath.bezierPath];
    }
    
    __block CGFloat y = 0;
    [self.dataSource.modelDataSource.visibleModels enumerateObjectsUsingBlock:^(id<HyChartBarModelProtocol>  _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
        [model.values enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            y = obj.doubleValue * heightRate;
            [paths[idx] appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(model.visiblePosition + (idx * oneBarWidth),  y, oneBarWidth, height - y)]];
        }];
    }];
        
    [self.layers enumerateObjectsUsingBlock:^(CAShapeLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.path = paths[idx].CGPath;
    }];
}

- (NSArray<CAShapeLayer *> *)layers {
    if (!_layers){
        NSMutableArray<CAShapeLayer *> *mArray = @[].mutableCopy;
        NSInteger count = self.dataSource.modelDataSource.models.firstObject.values.count;
        for (NSInteger i = 0; i < count; i++) {
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.frame = self.bounds;
            if (self.dataSource.configreDataSource.configure.barConfigureAtIndexBlock) {
                HyChartBarOneConfigure *configure = HyChartBarOneConfigure.defaultConfigure;
                self.dataSource.configreDataSource.configure.barConfigureAtIndexBlock(i, configure);
                layer.fillColor = configure.fillColor.CGColor;
                layer.strokeColor = configure.strokeColor.CGColor;
                layer.lineWidth = configure.lineWidth;
            }
            layer.masksToBounds = YES;
            [self addSublayer:layer];
            [mArray addObject:layer];
        }
        _layers = mArray.copy;
    }
    return _layers;
}


- (void)addLayerAnimation:(CAShapeLayer *)layer needDellegate:(BOOL)need {

    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    if (need) { basic.delegate = self;}
    basic.duration = 0.01;
    basic.fromValue = @(0);
    basic.toValue = @(1);
    basic.autoreverses = NO;
    basic.fillMode = kCAFillModeForwards;
    [layer addAnimation:basic forKey:nil];
}

@end