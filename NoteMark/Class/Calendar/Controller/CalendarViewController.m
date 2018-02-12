//
//  CalendarViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/24.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

static const int scrollSubViewCount = 3;
static const CGFloat scrollViewHeight = 330;

#import "CalendarViewController.h"
#import "RecordViewController.h"

@interface CalendarViewController () <UIScrollViewDelegate>
{
    NSUInteger _titleMonth;
    NSUInteger _titleYear;
    
    NSString *_currentMonth;
    NSUInteger _currentDay;
    
    NSUInteger _indexDay;
    
    UIButton *_selectButton;
}

@property (nonatomic, weak) UIView *currentView;

@property (nonatomic, assign) NSInteger preIndex;

@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *threeMonthDays;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _threeMonthDays = [NSMutableArray array];
    [self setupUI];
    [self setupBaseData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recordChanged) name:@"recordChanged" object:nil];
}

#pragma mark 记录修改之后完成
- (void)recordChanged {
    
    //  保存本月月份的日期
    NSMutableArray *dayArray = [self getDayArrWithMonth:_titleMonth year:_titleYear];
    [_threeMonthDays replaceObjectAtIndex:1 withObject:dayArray];
    
    UIView *bgView = self.scrollView.subviews[1];
    for (UIView *view in bgView.subviews) {
        [view removeFromSuperview];
    }
    [self setupDetailWithArr:_threeMonthDays[1] fatherView:bgView];
}

#pragma mark - viewDidLoad
#pragma mark setupUI
- (void)setupUI{
    
    self.view.backgroundColor = GlobalBGColor;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"记" style:UIBarButtonItemStyleDone target:self action:@selector(toRecordVC)];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy年MM月";
    self.title = [dateFormatter stringFromDate:date];
    
    _currentMonth = self.title;
    dateFormatter.dateFormat = @"dd";
    _currentDay = [[dateFormatter stringFromDate:date] integerValue];
    _indexDay = _currentDay;
    
    CGFloat weekHeight = 30;
    UIView *weekView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, weekHeight)];
    weekView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:weekView];
    
    NSArray *weekArr = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    
    CGFloat weekCount = weekArr.count;
    CGFloat labelW = 30;
    CGFloat marginX = (SCREEN_WIDTH - labelW * weekCount) / (weekCount + 1);
    for (int i = 0; i < weekCount; i++) {
        
        CGFloat labelX = i * (marginX + labelW) + marginX;
        
        UILabel *weekLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 0, labelW, weekHeight)];
        weekLabel.font = [UIFont systemFontOfSize:12.0];
        weekLabel.text = weekArr[i];
        weekLabel.textColor = TextEnableColor;
        weekLabel.textAlignment = NSTextAlignmentCenter;
        [weekView addSubview:weekLabel];
    }
    
    CGFloat scrollY = CGRectGetMaxY(weekView.frame);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, scrollY, SCREEN_WIDTH, scrollViewHeight)];
    scrollView.delegate = self;
    scrollView.pagingEnabled = YES;
    scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * 3, 0);
    scrollView.scrollEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    [self.view addSubview:scrollView];
    _scrollView = scrollView;
}

- (void)toRecordVC {
    
    NSString *dayStr = [NSString stringWithFormat:@"%@%02ld日", self.title, _indexDay];
    NSDictionary *recordDict = [YJTool queryPeriodWithDay:dayStr];
    
    RecordViewController *recordVC = [[RecordViewController alloc] init];
    recordVC.recordDict = recordDict;
    recordVC.recordDate = dayStr;
    [self.navigationController pushViewController:recordVC animated:YES];
}

#pragma mark 设置数据
- (void)setupBaseData {
    
    _titleMonth = [[self.title substringWithRange:NSMakeRange(5, 2)] integerValue];
    _titleYear = [[self.title substringWithRange:NSMakeRange(0, 4)] integerValue];
    
    //  保存上个月份的日期
    NSUInteger preMonth = _titleMonth == 1 ? 12 : _titleMonth - 1;
    NSUInteger preYear = _titleMonth == 1 ? _titleYear - 1 : _titleYear;
    NSMutableArray *preDayArray = [self getDayArrWithMonth:preMonth year:preYear];
    [_threeMonthDays addObject:preDayArray];
    
    //  保存本月月份的日期
    NSMutableArray *dayArray = [self getDayArrWithMonth:_titleMonth year:_titleYear];
    [_threeMonthDays addObject:dayArray];
    
    //  保存下个月月份的日期
    NSUInteger nextMonth = _titleMonth == 12 ? 1 : _titleMonth + 1;
    NSUInteger nextYear = _titleMonth == 12 ? _titleYear + 1 : _titleYear;
    NSMutableArray *nextDayArray = [self getDayArrWithMonth:nextMonth year:nextYear];
    [_threeMonthDays addObject:nextDayArray];
    
    [self setupDetail];
}

- (NSMutableArray *)getDayArrWithMonth:(NSUInteger)month year:(NSUInteger)year {
    
    NSInteger daysInMonth = [DateUtils daysInMonth:month ofYear:year];
    
    NSUInteger nextMonth = month == 12 ? 1 : month + 1;
    NSUInteger preMonth = month == 1 ? 12 : month - 1;
    NSUInteger preYear = preMonth == 12 ? year - 1 : year;
    NSInteger daysInpreviousMonth = [DateUtils daysInMonth:preMonth ofYear:preYear];
    
    NSInteger firstComponents = [DateUtils weekdayInMonth:month ofYear:year ofDay:1];
    NSInteger lastComponents = [DateUtils weekdayInMonth:month ofYear:year ofDay:daysInMonth];
    
    NSMutableArray *dayArr = [NSMutableArray array];
    
    NSString *currentMonthAndYear = [NSString stringWithFormat:@"%04ld年%02ld月", year, month];
    NSArray *timeArr = [YJTool queryPeriodWithMonth:currentMonthAndYear];
    YJLog(@"year - month: %ld-%ld timeArr:%@", year, month, timeArr);
    
    BOOL currentMonthFlag = [currentMonthAndYear isEqualToString:_currentMonth];
    
    for (int i = 1; i < firstComponents; i++) {
        NSString *dayStr = [NSString stringWithFormat:@"%ld", (daysInpreviousMonth - firstComponents + 1 + i)];
        [dayArr addObject:@{
                            @"dayStr":dayStr,
                            @"dayType":@"preDay"
                            }];
    }
    for (int i = 0; i < daysInMonth; i++) {
        
        BOOL needAddFlag = TRUE;
        NSString *dayStr = [NSString stringWithFormat:@"%d", (i + 1)];
        if (currentMonthFlag && [dayStr integerValue] == _currentDay) {
            dayStr = @"今";
        }
        
        if (timeArr.count > 0) {
            
            for (NSDictionary *dict in timeArr) {
                
                BOOL wholeFlag = FALSE;
                NSString *startTime = dict[@"startTime"];
                NSString *endTime = dict[@"endTime"];
                
                NSInteger startDay = 0;
                NSInteger startMonth = 0;
                if (startTime.length > 4) {
                    startDay = [[startTime substringWithRange:NSMakeRange(8, 2)] integerValue];
                    startMonth = [[startTime substringWithRange:NSMakeRange(5, 2)] integerValue];
                }
                NSInteger endDay = 0;
                NSInteger endMonth = 0;
                if (endTime.length > 4) {
                    endDay = [[endTime substringWithRange:NSMakeRange(8, 2)] integerValue];
                    endMonth = [[endTime substringWithRange:NSMakeRange(5, 2)] integerValue];
                }
                
                if (startTime.length > 4 && endTime.length > 4) {
                    wholeFlag = TRUE;
                }
                
                if (wholeFlag && (((i + 1) <= endDay && (i + 1) >= startDay) || (preMonth == startMonth && (i + 1) <= endDay) || (nextMonth == endMonth && (i + 1) >= startDay))) {
                    
                    needAddFlag = FALSE;
                    NSString *typeFlag = (i + 1) == startDay ? @"startType" : @"";
                    
                    if ([typeFlag isEqualToString:@""]) {
                        typeFlag = (i + 1) == endDay ? @"endType" : @"";
                    }
                    if ([typeFlag isEqualToString:@""]) {
                        typeFlag = @"middle";
                    }
                    if ((i + 1) == startDay && startDay == endDay) {
                        typeFlag = @"both";
                    }
                    
                    [dayArr addObject:@{
                                        @"dayStr":dayStr,
                                        @"dayType":@"nowadays",
                                        @"type":typeFlag
                                        }];
                    break;
                }else if (startDay > 0 && startDay == i + 1 && startMonth == month) {
                    
                    needAddFlag = FALSE;
                    [dayArr addObject:@{
                                        @"dayStr":dayStr,
                                        @"dayType":@"nowadays",
                                        @"type":@"startOnly"
                                        }];
                    break;
                }else if (endDay > 0 && endDay == i + 1 && endMonth == month) {
                    
                    needAddFlag = FALSE;
                    [dayArr addObject:@{
                                        @"dayStr":dayStr,
                                        @"dayType":@"nowadays",
                                        @"type":@"endOnly"
                                        }];
                    break;
                }
            }
        }
        
        if (needAddFlag) {
            
            [dayArr addObject:@{
                                @"dayStr":dayStr,
                                @"dayType":@"nowadays",
                                @"type":@"normal"
                                }];
        }
    }
    for (int i = 1; i <= 7 - lastComponents; i++) {
        
        [dayArr addObject:@{
                            @"dayStr":[NSString stringWithFormat:@"%d", i],
                            @"dayType":@"future"
                            }];
    }
    return dayArr;
}

#pragma mark 设置数据相关的UI部分
- (void)setupDetail {
    
    for(int i = 0; i < scrollSubViewCount; i++) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, SCREEN_WIDTH, scrollViewHeight)];
        [_scrollView addSubview:bgView];
        
        [self setupDetailWithArr:_threeMonthDays[i] fatherView:bgView];
    }
}

- (void)setupDetailWithArr:(NSMutableArray *)daysArray fatherView:(UIView *)fatherView {
    
    CGFloat buttonWH = 30;
    NSInteger columns = 7;
    CGFloat marginX = (SCREEN_WIDTH - buttonWH * columns) / (columns + 1);
    NSInteger rows = daysArray.count / columns;
    CGFloat marginY = (scrollViewHeight - buttonWH * rows - 7) / (rows);
    
    UIView *currentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 38, 38)];
    currentView.backgroundColor = [UIColor clearColor];
    currentView.layer.cornerRadius = 19;
    currentView.clipsToBounds = YES;
    [fatherView addSubview:currentView];
    if ([_threeMonthDays indexOfObject:daysArray] == 1) {
        
        _currentView = currentView;
    }
    
    for (int i = 0; i < daysArray.count; i++) {
        
        NSDictionary *dict = daysArray[i];
        
        NSInteger currentCol = i % columns;
        NSInteger currentRow = i / columns;
        CGFloat buttonX = currentCol * (marginX + buttonWH) + marginX;
        CGFloat buttonY = currentRow * (marginY + buttonWH) + 7;
        
        UIButton *dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dateButton.frame = CGRectMake(buttonX, buttonY, buttonWH, buttonWH);
        [dateButton setTitle:dict[@"dayStr"] forState:UIControlStateNormal];
        
        [dateButton setTitleColor:TextEnableColor forState:UIControlStateNormal];
        if ([dict[@"dayType"] isEqualToString:@"nowadays"]) {
            
            NSInteger indexDay = 0;
            if ([dict[@"dayStr"] isEqualToString:@"今"]) {
                indexDay = _currentDay;
            }else {
                indexDay = [dict[@"dayStr"] integerValue];
            }
            
            if (_indexDay == indexDay) {
                
                currentView.center = dateButton.center;
                currentView.backgroundColor = TextBgBlueColor;
            }
            
            dateButton.layer.cornerRadius = 15;
            dateButton.clipsToBounds = YES;
            
            [dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            if ([dict[@"type"] isEqualToString:@"startType"]) {
                dateButton.backgroundColor = TextBgPinkDarkColor;
            }else if ([dict[@"type"] isEqualToString:@"endType"]) {
                dateButton.backgroundColor = TextBgPinkLightColor;
            }else if ([dict[@"type"] isEqualToString:@"both"]) {
                dateButton.backgroundColor = TextBgPurpleLightColor;
            }else if ([dict[@"type"] isEqualToString:@"middle"]) {
                dateButton.backgroundColor = TextBgPinkColor;
            }else if ([dict[@"type"] isEqualToString:@"startOnly"]) {
                dateButton.backgroundColor = RGBCOLOR(228, 155, 160);
            }else if ([dict[@"type"] isEqualToString:@"endOnly"]) {
                dateButton.backgroundColor = RGBCOLOR(233, 160, 180);
            }else {
                [dateButton setTitleColor:TextDardColor forState:UIControlStateNormal];
            }
        }
        [dateButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [fatherView addSubview:dateButton];
    }
}

#pragma mark - UIScrollViewDelegate
#pragma mark setContentOffset滚动结束时调用
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
    CGFloat width = _scrollView.bounds.size.width;
    [self updateContent];
    self.scrollView.contentOffset = CGPointMake(width, 0);
}

#pragma mark 自动滚动结束时调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat width = _scrollView.bounds.size.width;
    _preIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    [self updateContent];
    self.scrollView.contentOffset = CGPointMake(width, 0);
}

- (void)updateContent {
    
    if (_preIndex == 2) {
        
        _titleMonth = _titleMonth == 12 ? 1 : _titleMonth + 1;
        _titleYear = _titleMonth == 1 ? _titleYear + 1 : _titleYear;
        
        self.title = [NSString stringWithFormat:@"%04lu年%02lu月", (unsigned long)_titleYear, (unsigned long)_titleMonth];
        
        NSUInteger nextMonth = _titleMonth == 12 ? 1 : _titleMonth + 1;
        NSUInteger nextYear = _titleMonth == 12 ? _titleYear + 1 : _titleYear;
        
        [_threeMonthDays removeObjectAtIndex:0];
        NSArray *nextArr = [self getDayArrWithMonth:nextMonth year:nextYear];
        [_threeMonthDays addObject:nextArr];
        
    }else if (_preIndex == 0) {
        
        _titleMonth = _titleMonth == 1 ? 12 : _titleMonth - 1;
        _titleYear = _titleMonth == 12 ? _titleYear - 1 : _titleYear;
        
        self.title = [NSString stringWithFormat:@"%04lu年%02lu月", (unsigned long)_titleYear, (unsigned long)_titleMonth];
        
        NSUInteger preMonth = _titleMonth == 1 ? 12 : _titleMonth - 1;
        NSUInteger preYear = _titleMonth == 1 ? _titleYear - 1 : _titleYear;
        
        [_threeMonthDays removeLastObject];
        NSArray *preArr = [self getDayArrWithMonth:preMonth year:preYear];
        [_threeMonthDays insertObject:preArr atIndex:0];
    }
    
    for (int i = 0; i < scrollSubViewCount; i++) {
        //取出三个imageBtn
        UIView *bgView = self.scrollView.subviews[i];
        for (UIView *view in bgView.subviews) {
            [view removeFromSuperview];
        }
        [self setupDetailWithArr:_threeMonthDays[i] fatherView:bgView];
    }
}

- (void)buttonClicked:(UIButton *)button {
    
    _selectButton = button;
    _currentView.center = button.center;
    UIColor *textColor = [_selectButton titleColorForState:UIControlStateNormal];
    
    
    if ([[_selectButton titleForState:UIControlStateNormal] isEqualToString:@"今"]) {
        _indexDay = _currentDay;
    }else {
        _indexDay = [[_selectButton titleForState:UIControlStateNormal] integerValue];
    }
    
    if (CGColorEqualToColor(textColor.CGColor, TextDardColor.CGColor) || CGColorEqualToColor(textColor.CGColor, [UIColor whiteColor].CGColor)) {
        
        
    }else if (![[_selectButton titleForState:UIControlStateNormal] isEqualToString:@"今"]) {
        
        NSInteger title = [[_selectButton titleForState:UIControlStateNormal] integerValue];
        if (title < 7) {
            _preIndex = 2;
            [_scrollView setContentOffset:CGPointMake(2 * SCREEN_WIDTH, 0) animated:YES];
        }else {
            _preIndex = 0;
            [_scrollView setContentOffset:CGPointMake(0 * SCREEN_WIDTH, 0) animated:YES];
        }
    }
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
