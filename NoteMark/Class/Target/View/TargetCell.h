//
//  TargetCell.h
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TargetModel.h"
@class TargetCell;

@protocol TargetCellDelegate <NSObject>

- (void)targetCellDidMark:(TargetCell *)cell;

@end

@interface TargetCell : UITableViewCell

@property (nonatomic, strong) TargetModel *target;

@property (nonatomic, weak) id<TargetCellDelegate> delegate;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
