//
//  YJPickerView.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//
#define kButtonHeight 44
#define ViewShowTime 0.25

#import "YJPickerView.h"

@interface YJPickerView ()
{
    CGFloat _totalHeight;
}

@property(nonatomic, weak) UIScrollView *totalView;

@end

@implementation YJPickerView

- (instancetype)initWithTitle:(NSString *)title subButtons:(NSArray *)titleArray {
    
    self = [super init];
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        UIView *grayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        grayView.backgroundColor = RGBACOLOR(0, 0, 0, 0.3);
        [self addSubview:grayView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSelf)];
        [grayView addGestureRecognizer:tapGesture];
        
        NSInteger buttonCount = titleArray.count;
        _totalHeight = buttonCount * (kButtonHeight + 0.5);
        CGFloat scrollHeight = _totalHeight;
        
        if (_totalHeight > (SCREEN_HEIGHT - NAVIGATION_ADD_STATUSBAR_HEIGHT) / 2) {
            _totalHeight = (SCREEN_HEIGHT - NAVIGATION_ADD_STATUSBAR_HEIGHT) / 2 - 50;
        }
        
        if (![title isEqualToString:@""]) {
            _totalHeight += 34;
        }
        
        //  1. 白色父类View
        UIScrollView *totalView = [[UIScrollView alloc] init];
        totalView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, _totalHeight);
        totalView.backgroundColor = [UIColor clearColor];
        totalView.contentSize = CGSizeMake(0, scrollHeight);
        [grayView addSubview:totalView];
        _totalView = totalView;
        
        CGFloat firstButtonY = 0;
        if (![title isEqualToString:@""]) {
            
            //  1.1. 确定要推出登陆吗？标题
            CGFloat labelY = 0;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, labelY, SCREEN_WIDTH, 33)];
            label.backgroundColor = [UIColor whiteColor];
            label.text = title;
            label.textAlignment = NSTextAlignmentCenter;
            label.font = [UIFont systemFontOfSize:12.0];
            label.textColor = TextLightColor;
            [totalView addSubview:label];
            
            //  分割线
            CGFloat dividerY = CGRectGetMaxY(label.frame);
            UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, dividerY, SCREEN_WIDTH, 1)];
            dividerView.backgroundColor = GlobalBGColor;
            [totalView addSubview:dividerView];
            firstButtonY = dividerY + 1;
        }
        
        for (int i = 0; i < buttonCount; i++) {
            
            //  1.2. 确定按钮
            CGFloat buttonY = firstButtonY + (kButtonHeight + 0.5) * i;
            UIButton *normalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, buttonY, SCREEN_WIDTH, kButtonHeight)];
            normalButton.backgroundColor = [UIColor whiteColor];
            normalButton.titleLabel.font = [UIFont systemFontOfSize:20];
            [normalButton setTitle:titleArray[i] forState:UIControlStateNormal];
            UIImage *highImage = [YJTool createImageWithColor:TextLightColor];
            [normalButton setBackgroundImage:highImage forState:UIControlStateHighlighted];
            [normalButton setTitleColor:TextDardColor forState:UIControlStateNormal];
            [normalButton setTitleColor:GlobalColor forState:UIControlStateHighlighted];
            [normalButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [totalView addSubview:normalButton];
        }
    }
    return self;
}

#pragma mark - 按钮点击，通知代理
- (void)buttonClick:(UIButton *)button {
    
    //判断其他类有没有实现可选协议方法
    if ([self.delegate respondsToSelector:@selector(pickerView:clickedTitle:)]) {
        
        [self.delegate pickerView:self clickedTitle:[button titleForState:UIControlStateNormal]];
        
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
