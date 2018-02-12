//
//  TargetViewController.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/3.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "TargetViewController.h"
#import "TargetNoteViewController.h"
#import "TargetCell.h"
#import "TargetModel.h"

@interface TargetViewController ()
{
    NSMutableArray *_targets;
}

@end

@implementation TargetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"小目标";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"记" style:UIBarButtonItemStyleDone target:self action:@selector(toRecordVC)];
    self.tableView.rowHeight = 75;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    headerView.backgroundColor = GlobalBGColor;
    self.tableView.tableHeaderView = headerView;
    
    [self setupData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupData) name:@"targetAdded" object:nil];
}

- (void)setupData {
    
    _targets = [YJTool queryTargets];
    [self.tableView reloadData];
}

- (void)toRecordVC {
    
    TargetNoteViewController *noteVC = [[TargetNoteViewController alloc] init];
    [self.navigationController pushViewController:noteVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _targets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TargetCell *cell = [TargetCell cellWithTableView:tableView];
    cell.target = _targets[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        //        通过获取的索引值删除数组中的值
        TargetModel *target = _targets[indexPath.row];
        [YJTool deleteTarget:target.targetId];
        [_targets removeObject:target];
        
        //        删除单元格的某一行时，在用动画效果实现删除过程
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TargetNoteViewController *noteVC = [[TargetNoteViewController alloc] init];
    noteVC.targetModel = _targets[indexPath.row];
    [self.navigationController pushViewController:noteVC animated:YES];
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
