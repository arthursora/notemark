//
//  LuckyCell.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/24.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "LuckyCell.h"

@interface LuckyCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *dividerView;

@end

@implementation LuckyCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    static NSString *ID = @"luckyCell";
    LuckyCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LuckyCell" owner:nil options:nil][0];
    }
    return cell;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    _iconView.contentMode = UIViewContentModeScaleToFill;
    _timeLabel.textColor = TextDardColor;
    _contentLabel.textColor = TextDardColor;
    _dividerView.backgroundColor = GlobalBGColor;
}

- (void)setLuckyDict:(NSDictionary *)luckyDict {
    
    _iconView.image = [UIImage imageWithData:luckyDict[@"imgData"]];
    
    _timeLabel.text = luckyDict[@"recordDate"];
    _contentLabel.text = luckyDict[@"content"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
