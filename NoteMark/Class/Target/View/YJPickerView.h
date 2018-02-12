//
//  YJPickerView.h
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YJPickerView;

@protocol YJPickerViewDelegate <NSObject>

- (void)pickerView:(YJPickerView *)pickerView clickedTitle:(NSString *)title;

@end


@interface YJPickerView : UIView

@property (nonatomic, weak) id<YJPickerViewDelegate> delegate;

- (instancetype)initWithTitle:(NSString *)title subButtons:(NSArray *)titleArray;

- (void)appearAlertView;

@end
