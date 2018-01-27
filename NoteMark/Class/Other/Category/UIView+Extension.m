//
//  UIView+Extension.m
//  CarService
//
//  Created by 徐朝飞 on 2017/3/11.
//  Copyright © 2017年 YiJu. All rights reserved.
//


@implementation UIView (Extension)

-(void)setWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(CGFloat)width{
    
    return self.frame.size.width;
}

-(void)setHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;

}

-(CGFloat)height{
    return self.frame.size.height;
}

-(void)setX:(CGFloat)X{

    CGRect frame = self.frame;
    frame.origin.x = X;
    self.frame = frame;


}
-(CGFloat)X{
    return self.frame.origin.x;
}

-(void)setY:(CGFloat)Y{
    
    CGRect frame = self.frame;
    frame.origin.y = Y;
    self.frame = frame;
}

- (CGFloat)centerX {
    
    return self.X + self.width * 0.5;
}

- (void)setCenterX:(CGFloat)centerX {
    
    self.X = centerX - self.width * 0.5;
}

-(CGFloat)Y{
    return self.frame.origin.y;
}

@end
