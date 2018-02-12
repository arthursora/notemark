//
//  RecordViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/16.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "RecordViewController.h"

@interface RecordViewController ()

@property (nonatomic, weak) UISwitch *startSwitch;
@property (nonatomic, weak) UISwitch *endSwitch;

@end

@implementation RecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _recordDate;
    self.view.backgroundColor = GlobalBGColor;
    [self setupData];
}

- (void)setupData {
    
    CGFloat viewWidth = SCREEN_WIDTH;
    CGFloat viewHeight = 40;
    
    for (int i = 0; i < 2; i++) {
        
        CGFloat viewY = i * (viewHeight + 0.5) + 10;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, viewY, viewWidth, viewHeight)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 40)];
        nameLabel.text = i == 0 ? @"开始日期" : @"结束日期";
        nameLabel.textColor = TextDardColor;
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        [bgView addSubview:nameLabel];
        
        CGFloat dateSwitchW = 100;
        CGFloat dateSwitchX = viewWidth - dateSwitchW + 10;
        UISwitch *dateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(dateSwitchX, 5, dateSwitchW, 30)];
        dateSwitch.transform = CGAffineTransformMakeScale(0.8, 0.8);
        dateSwitch.layer.anchorPoint = CGPointMake(0, 0.5);
        [dateSwitch setOn:NO animated:NO];
        
        //        dateSwitch.tintColor = TextEnableColor;
        //        dateSwitch.offImage = [YJTool createImageWithColor:TextEnableColor];
        dateSwitch.onTintColor = TextBgPinkColor;
        [bgView addSubview:dateSwitch];
        
        if (i == 0) {
            _startSwitch = dateSwitch;
        }else {
            _endSwitch = dateSwitch;
        }
    }
    
    NSString *startTime = _recordDict[@"startTime"];
    NSString *endTime = _recordDict[@"endTime"];
    if ([startTime isEqualToString:self.title]) {
        [_startSwitch setOn:YES animated:YES];
    }
    if ([endTime isEqualToString:self.title]) {
        [_endSwitch setOn:YES animated:YES];
    }
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(MarginWidth, 100, MaxViewWidth, 40);
    submitButton.backgroundColor = TextBgBlueColor;
    [submitButton setTitle:@"保存" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

- (void)buttonClicked {
    
    [self presentLoadingTips:@""];
    NSString *startTime = @"";
    NSString *endTime = @"";
    if (_startSwitch.isOn) {
        startTime = self.title;
    }
    if (_endSwitch.isOn) {
        endTime = self.title;
    }
    if (!_startSwitch.isOn && !_endSwitch.isOn) {
        
        [YJTool deletePeriod:self.title];
    }else {
        [YJTool addPeriod:startTime endTime:endTime];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"recordChanged" object:nil];
    [self dismissTips];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
