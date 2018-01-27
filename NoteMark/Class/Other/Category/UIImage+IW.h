//
//  UIImage+IW.h
//  微博
//
//  Created by 朱亚杰 on 15/6/29.
//  Copyright (c) 2015年 朱亚杰. All rights reserved.
//
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
#import <UIKit/UIKit.h>

@interface UIImage (IW)

#pragma mark - 加载项目中所有图片（适配）
+ (UIImage *)imageWithName:(NSString *)name;

#pragma mark － 加载拉伸图片
+ (UIImage *)resizedImage:(NSString *)name;

#pragma mark － 加载拉伸图片
+ (UIImage *)resizedImage:(NSString *)name leftScale:(CGFloat)leftScale topScale:(CGFloat)topScale;

@end
