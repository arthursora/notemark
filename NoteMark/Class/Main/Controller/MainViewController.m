//
//  MainViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/10.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "MainViewController.h"
#import "CalendarViewController.h"
#import "RecordLuckyViewController.h"
#import "LuckyCell.h"

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSArray *_records;
}

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self setupData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupData) name:@"luckyAdded" object:nil];
}

- (void)setupData {
    
    _records = [YJTool queryLuckies];
    [_tableView reloadData];
}

- (void)setupUI {
    
    self.title = @"Lucky";
    self.view.backgroundColor = GlobalBGColor;
    
    UITableView *tableView = [[UITableView alloc] init];
    CGFloat tableHeight = SCREEN_HEIGHT - NAVIGATION_ADD_STATUSBAR_HEIGHT - 1;
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 1, SCREEN_WIDTH, tableHeight) style:UITableViewStyleGrouped];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.rowHeight = 85;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tableView];
    _tableView = tableView;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 31)];
    headerView.backgroundColor = [UIColor whiteColor];
    NSArray *titleArray = @[@"日历", @"小幸运"];
    for (int i = 0; i < 2; i++) {
        
        CGFloat buttonX = i * SCREEN_WIDTH / 2;
        UIButton *normalButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, 0, SCREEN_WIDTH / 2, 30)];
        normalButton.backgroundColor = [UIColor whiteColor];
        normalButton.titleLabel.font = [UIFont systemFontOfSize:18.0];
        [normalButton setTitle:titleArray[i] forState:UIControlStateNormal];
        [normalButton setTitleColor:GlobalColor forState:UIControlStateNormal];
        normalButton.backgroundColor = [UIColor whiteColor];
        [normalButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [headerView addSubview:normalButton];
    }
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 1)];
    dividerView.backgroundColor = GlobalBGColor;
    [headerView addSubview:dividerView];
    tableView.tableHeaderView = headerView;
}

- (void)buttonClick:(UIButton *)button {
    
    NSString *titleStr = [button titleForState:UIControlStateNormal];
    if ([titleStr isEqualToString:@"日历"]) {
        
        CalendarViewController *calenderVC = [[CalendarViewController alloc] init];
        [self.navigationController pushViewController:calenderVC animated:YES];
    }else {
        RecordLuckyViewController *recordVC = [[RecordLuckyViewController alloc] init];
        [self.navigationController pushViewController:recordVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (_records) {
        return _records.count;
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    LuckyCell *luckyCell = [LuckyCell cellWithTableView:tableView];
    luckyCell.luckyDict = _records[indexPath.row];
    return luckyCell;
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
