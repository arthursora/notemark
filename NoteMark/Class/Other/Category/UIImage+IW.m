//
//  UIImage+IW.m
//  微博
//
//  Created by 朱亚杰 on 15/6/29.
//  Copyright (c) 2015年 朱亚杰. All rights reserved.
//

#import "UIImage+IW.h"

@implementation UIImage (IW)

+ (UIImage *)imageWithName:(NSString *)name {
    
    if (iOS7) {
        NSString *newName = [name stringByAppendingString:@"_os7"];
        UIImage *image = [UIImage imageNamed:newName];
        if (image == nil) {
            image = [UIImage imageNamed:name];
        }
        return image;
    } else {
        UIImage *image = [UIImage imageNamed:name];
        return image;
    }
}

#pragma mark － 加载拉伸图片
+ (UIImage *)resizedImage:(NSString *)name leftScale:(CGFloat)leftScale topScale:(CGFloat)topScale {
    
    UIImage *image = [self imageWithName:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * leftScale topCapHeight:image.size.height * topScale];
}

+ (UIImage *)resizedImage:(NSString *)name {
    
    return [self resizedImage:name leftScale:0.5 topScale:0.5];
}

@end
