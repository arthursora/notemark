//
//  CustomAlertView.h
//  CarService
//
//  Created by 徐朝飞 on 2017/3/21.
//  Copyright © 2017年 YiJu. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CustomAlertViewDelegate;


@interface CustomAlertView : UIView

//  声明一个属性去接收ViewController的对象
@property (nonatomic, weak) id  delegate;

//  定义CustomAlertView的初始化方法。
- (id)initWithTitle:(NSString *)title subButtons:(NSArray *)titleArray;

//  定义CustomAlertView展示方法。
- (void)appearAlertView;

@end

@protocol CustomAlertViewDelegate <NSObject>

- (void)alertView:(CustomAlertView *)customAlertView clickedButton:(NSString *)title;


@end
