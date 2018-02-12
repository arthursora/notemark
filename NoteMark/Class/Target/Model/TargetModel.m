//
//  TargetModel.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/2/3.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "TargetModel.h"

@implementation TargetModel

+ (instancetype)targetWithName:(NSString *)name joinTime:(NSString *)joinTime expectDays:(NSString *)expectDays award:(NSString *)award {
    
    TargetModel *targetModel = [[TargetModel alloc] init];
    targetModel.name = name;
    
    if ([joinTime containsString:@"任性"]) {
        joinTime = @"100";
    }
    
    targetModel.joinTime = [joinTime integerValue];
    targetModel.expectDays = [expectDays integerValue];
    targetModel.award = award;
    
    return targetModel;
}

@end
