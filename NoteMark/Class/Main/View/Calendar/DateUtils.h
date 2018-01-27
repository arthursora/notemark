//
//  DateUtils.h
//  NoteMark
//
//  Created by 朱亚杰 on 2017/12/4.
//  Copyright © 2017年 朱亚杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateUtils : NSObject

//  日期
+ (NSCalendar *)localCalendar;

+ (NSDate *)dateWithMonth:(NSUInteger)month year:(NSUInteger)year;

+ (NSDate *)dateWithMonth:(NSUInteger)month day:(NSUInteger)day year:(NSUInteger)year;

+ (NSDate *)dateFromDateComponents:(NSDateComponents *)components;

//  某年某月的天数
+ (NSUInteger)daysInMonth:(NSUInteger)month ofYear:(NSUInteger)year;

+ (NSUInteger)weekdayInMonth:(NSUInteger)month ofYear:(NSUInteger)year ofDay:(NSUInteger)day;

+ (NSString *)stringOfWeekdayInEnglish:(NSUInteger)weekday;

+ (NSString *)stringOfMonthInEnglish:(NSUInteger)month;

+ (NSDateComponents *)dateComponentsFromDate:(NSDate *)date;

+ (NSString *)stringFromDate:(NSDate *)date;

+ (BOOL)isDateTodayWithDateComponents:(NSDateComponents *)dateComponents;


@end
