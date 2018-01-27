//
//  CustomAlertView.m
//  CarService
//
//  Created by 徐朝飞 on 2017/3/21.
//  Copyright © 2017年 YiJu. All rights reserved.
//

#define ViewShowTime 0.25

#import "CustomAlertView.h"

@interface CustomAlertView()
{
    CGFloat _totalHeight;
}

@property(nonatomic, weak)UIView *totalView;

@end

@implementation CustomAlertView

- (id)initWithTitle:(NSString *)title subButtons:(NSArray *)titleArray {
    
    self = [super init];
    if (self) {
        
        //这里面的self指的就是viewController类中的alertView对象，其实也是一个view。
        //当前的self这个view包含两部分：1，灰色的背景；2，中间的警告框；
        
        //首先设置self的位置坐标，然后再往这个self上添加背景和中间的警告框；
        
        self.frame = [UIScreen mainScreen].bounds;
        UIView *grayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        grayView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [self addSubview:grayView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
        [grayView addGestureRecognizer:tapGesture];
        
        //往self上添加灰色半透明的背景
        NSInteger buttonCount = titleArray.count;
        _totalHeight = 57 * buttonCount + 8 + 0.5 * (titleArray.count - 2);
        
        if (![title isEqualToString:@""]) {
            _totalHeight += 34;
        }
        if ([title isEqualToString:@"lastSame"]) {
            _totalHeight -= 8;
        }
        
        //  1. 白色父类View
        UIView *whiteView = [[UIView alloc] init];
        whiteView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _totalHeight);
        whiteView.backgroundColor = [UIColor clearColor];
        [grayView addSubview:whiteView];
        _totalView = whiteView;
        
        CGFloat firstButtonY = 0;
        if (![title isEqualToString:@""] && ![title isEqualToString:@"lastSame"]) {
            
            //  1.1. 确定要推出登陆吗？标题
            CGFloat labelY = 0;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, SCREEN_WIDTH, 33)];
            label.backgroundColor = [UIColor whiteColor];
            label.text = title;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = TextLightColor;
            [whiteView addSubview:label];
            
            //  分割线
            CGFloat dividerY = CGRectGetMaxY(label.frame);
            UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, dividerY, SCREEN_WIDTH, 1)];
            dividerView.backgroundColor = GlobalBGColor;
            [whiteView addSubview:dividerView];
            firstButtonY = dividerY + 1;
        }
        
        for (int i = 0; i < buttonCount; i++) {
            
            //  1.2. 确定按钮
            CGFloat buttonH = 57;
            CGFloat buttonY = firstButtonY + (buttonH + 0.5) * i;
            if (![title isEqualToString:@"lastSame"]) {
                if (i == buttonCount - 1) {
                    buttonY = _totalHeight - buttonH;
                }
            }
            UIButton *normalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonY, SCREEN_WIDTH, buttonH)];
            normalButton.backgroundColor = [UIColor whiteColor];
            normalButton.titleLabel.font = [UIFont systemFontOfSize:20];
            [normalButton setTitle:titleArray[i] forState:UIControlStateNormal];
            UIImage *highImage = [YJTool createImageWithColor:TextLightColor];
            [normalButton setBackgroundImage:highImage forState:UIControlStateHighlighted];
            
            //  如果按钮数量大于3，则设置颜色位固定蓝色
            //  否则第一个按钮设为红色，其他按钮设为蓝色
            if (buttonCount > 3 || [title isEqualToString:@""]) {
                
                [normalButton setTitleColor:TextDardColor forState:UIControlStateNormal];
                [normalButton setTitleColor:GlobalColor forState:UIControlStateHighlighted];
            }else {
                if (i == 0) {
                    [normalButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }else {
                    [normalButton setTitleColor:GlobalColor forState:UIControlStateNormal];
                }
            }
            [normalButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [whiteView addSubview:normalButton];
        }
    }
    return self;
}

#pragma mark - 按钮点击，通知代理
- (void)buttonClick:(UIButton *)button {
    
    //判断其他类有没有实现可选协议方法
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButton:)]) {
        
        [self.delegate alertView:self clickedButton:[button titleForState:UIControlStateNormal]];
        
        [UIView animateWithDuration:ViewShowTime animations:^{
            
            CGRect frame = _totalView.frame;
            frame.origin.y += _totalHeight;
            _totalView.frame = frame;
            
        }completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        NSLog(@"其他类没有实现方法了");
    }
}

#pragma mark 点击灰色区隐藏自己
- (void)hideSelf {
    
    [UIView animateWithDuration:ViewShowTime animations:^{
        
        CGRect frame = _totalView.frame;
        frame.origin.y += _totalHeight;
        _totalView.frame = frame;
        
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

//调用该方法，要把alertView展示出来
- (void)appearAlertView {
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    window.backgroundColor = [UIColor blackColor];
    [window addSubview:self];
    
    [UIView animateWithDuration:ViewShowTime animations:^{
        
        CGRect frame = _totalView.frame;
        frame.origin.y -= _totalHeight;
        _totalView.frame = frame;
    }];
}

@end
