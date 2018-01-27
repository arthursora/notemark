//
//  NSString+Extension.m
//  MovieTicket
//
//  Created by 覃旭升 on 15/8/14.
//  Copyright (c) 2015年 Sam qin. All rights reserved.
//

#import "NSString+Extension.h"

@implementation NSString (Extension)

//把字典转换成json字符串
+(NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (NSString *)pinyin
{
    NSString *str = [self mutableCopy];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    return str;
}


//获取时间戳---time_stamp 为当前时间到 1970 年的毫秒数
+(NSString *)getTimeStamp
{
    NSTimeInterval time=[[NSDate date] timeIntervalSince1970]*1000;
    double time_stamp=time;//NSTimeInterval返回的是double类型
    return [NSString stringWithFormat:@"%0.0f",time_stamp];
}


- (NSString *)URLEncodedString
{
    /*
     CFURLCreateStringByAddingPercentEscapes函数是Core Foundation框架提供的C函数，可以把内容转换成URL【资源定位符】编码，
     
     */
    
    NSString *result = ( NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              NULL,//指定了将本身为非法的URL字符不进行编码的字符集合
                                                              CFSTR("!*();+$,%#[] "),//将本身为合法的URL字符需要进行编码的字符集合
                                                              kCFStringEncodingUTF8));
    return result;
}

- (NSString*)URLDecodedString
{
    //    CFURLCreateStringByReplacingPercentEscapesUsingEncoding与CFURLCreateStringByAddingPercentEscapes相反，是进行URL解码
    NSString *result = ( NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                              (CFStringRef)self,
                                                                              CFSTR(""),//指定不进行解码的字符集
                                                                              kCFStringEncodingUTF8));
    return result;
}

//获取文件夹或文件的大小
- (NSInteger)fileSize
{
    NSFileManager *mgr = [NSFileManager defaultManager];
    // 判断是否为文件
    BOOL dir = NO;
    BOOL exists = [mgr fileExistsAtPath:self isDirectory:&dir];
    // 文件\文件夹不存在
    if (exists == NO) return 0;
    
    if (dir) { // self是一个文件夹
        // 遍历caches里面的所有内容 --- 直接和间接内容
        NSArray *subpaths = [mgr subpathsAtPath:self];
        NSInteger totalByteSize = 0;
        for (NSString *subpath in subpaths) {
            // 获得全路径
            NSString *fullSubpath = [self stringByAppendingPathComponent:subpath];
            // 判断是否为文件
            BOOL dir = NO;
            [mgr fileExistsAtPath:fullSubpath isDirectory:&dir];
            if (dir == NO) { // 文件
                totalByteSize += [[mgr attributesOfItemAtPath:fullSubpath error:nil][NSFileSize] integerValue];
            }
        }
        return totalByteSize;
    } else { // self是一个文件
        return [[mgr attributesOfItemAtPath:self error:nil][NSFileSize] integerValue];
    }
}


@end
