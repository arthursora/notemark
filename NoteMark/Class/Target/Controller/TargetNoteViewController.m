//
//  TargetNoteViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "TargetNoteViewController.h"
#import "YJPickerView.h"

@interface TargetNoteViewController () <YJPickerViewDelegate>
{
    NSMutableArray *_timeArr;
}

@property (nonatomic, weak) UITextField *nameField;
@property (nonatomic, weak) UILabel *joinTimeLabel;
@property (nonatomic, weak) UITextField *expectDaysField;
@property (nonatomic, weak) UITextField *awardField;

@end

@implementation TargetNoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupData];
}

- (void)setupData {
    
    if (_targetModel) {
        
        _nameField.text = _targetModel.name;
        _expectDaysField.text = [NSString stringWithFormat:@"%ld", _targetModel.expectDays];
        _awardField.text = _targetModel.award;
        
        if (_targetModel.joinTime == 100) {
            _joinTimeLabel.text = @"  任性，就不选，哈哈哈";
        }else {
            _joinTimeLabel.text = [NSString stringWithFormat:@"  %ld", _targetModel.joinTime];
        }
    }
    
    _timeArr = [NSMutableArray array];
    [_timeArr addObject:@"任性，就不选，哈哈哈"];
    
    for (int i = 5; i < 23; i++) {
        [_timeArr addObject:[NSString stringWithFormat:@"%d", i]];
    }
}

- (void)setupUI {
    
    self.title = @"订个小目标";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    bgView.backgroundColor = GlobalBGColor;
    [self.view addSubview:bgView];
    
    NSArray *fieldNameArr = @[@"* 目标", @"参与时间（若选择7，则必须在6～8点之间打卡，否则视为无效）", @"* 坚持多久（天）", @"* 完成奖励"];
    
    CGFloat viewHeight = 60;
    for (int i = 0; i < fieldNameArr.count; i++) {
        
        CGFloat viewY = i * (viewHeight + 0.5) + 30;
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(MarginWidth, viewY, MaxViewWidth, viewHeight)];
        bgView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bgView];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MaxViewWidth, 15)];
        nameLabel.text = fieldNameArr[i];
        nameLabel.textColor = TextDardColor;
        nameLabel.font = [UIFont systemFontOfSize:13.0];
        [bgView addSubview:nameLabel];
        
        CGFloat textY = CGRectGetMaxY(nameLabel.frame) + 5;
        UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(10, textY, MaxViewWidth - 10, 30)];
        textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 32)];
        textField.leftViewMode = UITextFieldViewModeAlways;
        textField.font = [UIFont systemFontOfSize:15];
        textField.textColor = TextDardColor;
        textField.layer.borderWidth = 1;
        textField.layer.borderColor = GlobalBGColor.CGColor;
        [bgView addSubview:textField];
        
        if (i == 0) {
            
            _nameField = textField;
            textField.keyboardType = UIKeyboardTypeDefault;
            
        }else if (i == 1) {
            
            UILabel *timeLabel = [[UILabel alloc] initWithFrame:textField.frame];
            timeLabel.textColor = TextDardColor;
            timeLabel.font = [UIFont systemFontOfSize:15.0];
            timeLabel.userInteractionEnabled = YES;
            timeLabel.layer.borderWidth = 1;
            timeLabel.layer.borderColor = GlobalBGColor.CGColor;
            [bgView addSubview:timeLabel];
            textField.hidden = YES;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timeSelect)];
            [timeLabel addGestureRecognizer:tapGesture];
            
            _joinTimeLabel = timeLabel;
            _joinTimeLabel.text = @"  任性，就不选，哈哈哈";
            
        }else if (i == 2) {
            
            _expectDaysField = textField;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            
        }else if (i == 3) {
            
            _awardField = textField;
            textField.keyboardType = UIKeyboardTypeDefault;
            
        }
    }
    
    CGFloat submitY = viewHeight * fieldNameArr.count + 60;
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(MarginWidth, submitY, MaxViewWidth, 40);
    submitButton.backgroundColor = GlobalColor;
    [submitButton setTitle:@"保存" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(saveTarget) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
}

- (void)timeSelect {
    
    [self.view endEditing:YES];
    YJPickerView *alertView = [[YJPickerView alloc] initWithTitle:@"" subButtons:_timeArr];
    alertView.delegate = self;
    [alertView appearAlertView];
}

- (void)pickerView:(YJPickerView *)pickerView clickedTitle:(NSString *)title {
    
    _joinTimeLabel.text = [NSString stringWithFormat:@"  %@", title];
}

- (void)saveTarget {
    
    NSString *name = _nameField.text;
    if ([YJTool isBlankString:name]) {
        [self presentFailureTips:@"请输入您的小目标！"];
        return;
    }
    
    NSString *expectDays = _expectDaysField.text;
    if ([YJTool isBlankString:expectDays]) {
        [self presentFailureTips:@"您能坚持多久呢？"];
        return;
    }
    
    NSString *award = _awardField.text;
    if ([YJTool isBlankString:expectDays]) {
        [self presentFailureTips:@"不给奖励 没有动力哦！"];
        return;
    }
    NSString *joinTime = _joinTimeLabel.text;
    
    [self presentLoadingTips:@""];
    
    TargetModel *targetModel = [TargetModel targetWithName:name joinTime:joinTime expectDays:expectDays award:award];
    
    if (_targetModel) {
        targetModel.targetId = _targetModel.targetId;
    }
    
    [YJTool addTarget:targetModel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"targetAdded" object:nil];
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
