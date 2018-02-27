//
//  TargetCell.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "TargetCell.h"

@interface TargetCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goalLabel;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *awardLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *markLabel;

@end

@implementation TargetCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"targetCell";
    TargetCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"TargetCell" owner:nil options:nil][0];
    }
    return cell;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(markSelf)];
    [_markLabel addGestureRecognizer:tapGesture];
}

- (void)markSelf {
    
    YJLog(@"--targetCellDidMark-- %@", self);
    if([_delegate respondsToSelector:@selector(targetCellDidMark:)]) {
        
        [_delegate targetCellDidMark:self];
    }
}

- (void)setTarget:(TargetModel *)target {
    
    _target = target;
    _nameLabel.text = target.name;
    _awardLabel.text = target.award;
    _goalLabel.text = [NSString stringWithFormat:@"%ld/%ld", _target.totalDays, target.expectDays];
    
    _progressView.progress = 0;
    if (target.expectDays != 0) {
        
        _progressView.progress = (float)_target.totalDays / target.expectDays;
    }
    if (_progressView.progress == 0.00) {
        _descLabel.text = @"请开始新的旅程";
    }else if (_progressView.progress >= 1) {
        _descLabel.text = @"快去领取奖赏吧";
    }else {
        _descLabel.text = [NSString stringWithFormat:@"仍需坚持%ld天，加油！", (target.expectDays - target.totalDays)];
    }
    
    if (_progressView.progress >= 1) {
        
        _markLabel.text = @"";
        _markLabel.userInteractionEnabled = NO;
    }else {
        _markLabel.text = @"打卡";
        _markLabel.userInteractionEnabled = YES;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
