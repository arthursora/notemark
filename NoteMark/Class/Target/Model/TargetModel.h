//
//  TargetModel.h
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/3.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TargetModel : NSObject

+ (instancetype)targetWithName:(NSString *)name joinTime:(NSString *)joinTime expectDays:(NSString *)expectDays award:(NSString *)award;

@property (nonatomic, assign) NSInteger targetId;
@property (nonatomic, copy) NSString *name;

//  开始时间
@property (nonatomic, copy) NSString *startTime;

//  最近一次 连续参与的 开始一天
@property (nonatomic, copy) NSString *lastJoinTime;

//  必须打卡的时间段（可以没有）
//  如果joinTime = 9 ，择必须在8-10点之间打卡
@property (nonatomic, assign) NSInteger joinTime;

//  总天数
@property (nonatomic, assign) NSInteger totalDays;

//  最近一次 连续参数天数
@property (nonatomic, assign) NSInteger continueDays;

//  期望参与时间（可以获得奖励的天数）
@property (nonatomic, assign) NSInteger expectDays;

//  奖励
@property (nonatomic, copy) NSString *award;

@end
