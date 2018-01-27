//
//  NSString+Extension.h
//  MovieTicket
//
//  Created by 覃旭升 on 15/8/14.
//  Copyright (c) 2015年 Sam qin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extension)



//把字典转换成json字符串
+(NSString*)dictionaryToJson:(NSDictionary *)dic;


- (NSString *)pinyin;

//获取时间戳---time_stamp 为当前时间到 1970 年的毫秒数
+(NSString *)getTimeStamp;


//把url里的中文转成UTF-8
- (NSString *)URLEncodedString;


- (NSString*)URLDecodedString;

//获取文件夹或文件的大小
- (NSInteger)fileSize;

@end
