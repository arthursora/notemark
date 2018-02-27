//
//  YJTool.m
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import "YJTool.h"
#import "FMDatabase.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <AudioToolbox/AudioToolbox.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation YJTool

static FMDatabase *_db;

+ (void)initialize {
    
    // 1.打开数据库
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"yiju.sqlite"];
    
//    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"commentTarget.sqlite"];
    
    _db = [FMDatabase databaseWithPath:path];
    [_db open];
    
    //  创建 日常 表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS lucky (id integer PRIMARY KEY AUTOINCREMENT, recordDate text NOT NULL, content text NOT NULL, imgData blob NOT NULL);"];
    
    //  创建 生理期时间段 表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS period (id integer PRIMARY KEY AUTOINCREMENT, startTime text, endTime text);"];
    
    //  创建 目标 表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS target (id integer PRIMARY KEY AUTOINCREMENT, name text NOT NULL, startTime text NOT NULL, lastJoinTime text, joinTime int NOT NULL, totalDays int, continueDays int, expectDays int NOT NULL, award text NOT NULL);"];
}

+ (BOOL)updateTarget:(TargetModel *)target {
    
    BOOL result = NO;
    
    NSString *currentTime = [self getCurrentTime];
    NSInteger joinTime = target.joinTime;
    if (joinTime != 100) {
        NSInteger hour = [[currentTime substringWithRange:NSMakeRange(11, 2)] integerValue];
        if (hour < joinTime - 1 || hour > joinTime + 1) {
            return result;
        }
    }
    
    target.totalDays++;
    
    NSString *lastJoinTime = target.lastJoinTime;
    
    //  第一次打卡，需要把lastJoinTime设为今天
    if([YJTool isBlankString:lastJoinTime]) {
        
        target.lastJoinTime = currentTime;
        target.continueDays++;
    }else {
        
        /**
         *  lastJoinTime = currentTime
         *  根据lastJoinTime和currentTime判断是连续打卡
         *  连续打卡，continueDays++，
         *  连续打卡，continueDays=1；
         */
        NSInteger days = [self getDifferenceByDate:target.lastJoinTime];
        target.lastJoinTime = currentTime;
        
        if (days == 0) {
            return result;
        }
        
        if (days == 1) {
            target.continueDays++;
        }else {
            target.continueDays = 1;
        }
    }
    
    result = [_db executeUpdateWithFormat:@"UPDATE target SET lastJoinTime = %@, continueDays = %ld, totalDays = %ld WHERE id = %ld", target.lastJoinTime, target.continueDays, target.totalDays, target.targetId];
    
    [self addLog:@"小目标打卡" result:result];
    
    return result;
}

+ (NSInteger)getDifferenceByDate:(NSString *)date {
    //获得当前时间
    NSDate *now = [NSDate date];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSDate *oldDate = [dateFormatter dateFromString:date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags = NSCalendarUnitDay;
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:oldDate  toDate:now  options:0];
    return [comps day];
}

#pragma mark 添加小目标
+ (BOOL)addTarget:(TargetModel *)target {
    
    NSString *recordDate = [self getCurrentTime];
    BOOL result;
    
    if (target.targetId) {
        
        result = [_db executeUpdateWithFormat:@"UPDATE target SET name = %@, joinTime = %ld, expectDays = %ld, award = %@ WHERE id = %ld", target.name, target.joinTime, target.expectDays, target.award, target.targetId];
        
        [self addLog:@"改变小目标" result:result];
    }else {
        result = [_db executeUpdateWithFormat:@"INSERT INTO target(name, startTime, joinTime, expectDays, award) values (%@, %@, %ld, %ld, %@)", target.name, recordDate, target.joinTime, target.expectDays, target.award];
        
        [self addLog:@"增加小目标" result:result];
    }
    return result;
}

+ (BOOL)deleteTarget:(NSInteger)targetId {
    
    BOOL result = [_db executeUpdateWithFormat:@"DELETE FROM target where id == %ld", targetId];
    [self addLog:@"删除小目标" result:result];
    return result;
}

#pragma mark - private methods
+ (void)addLog:(NSString *)text result:(BOOL)result {
    
    NSString *sucorFailStr = @"Failure";
    if (result) {
        sucorFailStr = @"Success";
    }
    YJLog(@"----%@ %@!----", text, sucorFailStr);
}

+ (NSString *)getCurrentTime {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    return [dateFormatter stringFromDate:[NSDate date]];
}

#pragma mark 查询记录列表
+ (NSMutableArray *)queryTargets {
    
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM target order by startTime desc"];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    while (set.next) {
        
        TargetModel *targetModel = [[TargetModel alloc] init];
        targetModel.targetId = [set intForColumn:@"id"];
        targetModel.name = [set stringForColumn:@"name"];
        targetModel.startTime = [set stringForColumn:@"name"];
        targetModel.joinTime = [set intForColumn:@"joinTime"];
        targetModel.expectDays = [set intForColumn:@"expectDays"];
        targetModel.award = [set stringForColumn:@"award"];
        targetModel.lastJoinTime = [set stringForColumn:@"lastJoinTime"];
        targetModel.totalDays = [set intForColumn:@"totalDays"];
        targetModel.continueDays = [set intForColumn:@"continueDays"];
        
        [infoArr addObject:targetModel];
    }
    return infoArr;
}

#pragma mark 添加记录
+ (BOOL)addLucky:(NSString *)text image:(NSData *)image luckyId:(NSInteger)luckyId {
    
    NSString *recordDate = [self getCurrentTime];
    
    BOOL result;
    if (luckyId == 0) {
        
        result = [_db executeUpdateWithFormat:@"INSERT INTO lucky(recordDate, content, imgData) values (%@, %@, %@)", recordDate, text, image];
    }else {
        result = [_db executeUpdateWithFormat:@"UPDATE lucky SET content = %@, imgData  = %@ WHERE id = %ld", text, image, luckyId];
    }
    
    [self addLog:@"增加小幸运" result:result];
    return result;
}

+ (BOOL)deleteLucky:(NSInteger)luckyId {
    
    BOOL result = [_db executeUpdateWithFormat:@"DELETE FROM lucky where id == %ld", luckyId];
    [self addLog:@"删除小幸运" result:result];
    return result;
}

#pragma mark 查询记录列表
+ (NSMutableArray *)queryLuckies {
    
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM lucky order by recordDate desc"];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    while (set.next) {
        
        NSDictionary *info = @{
                               @"id":@([set intForColumn:@"id"]),
                               @"recordDate":[set stringForColumn:@"recordDate"],
                               @"content":[set stringForColumn:@"content"],
                               @"imgData":[set dataForColumn:@"imgData"],
                               };
        [infoArr addObject:info];
    }
    return infoArr;
}

+ (BOOL)addPeriod:(NSString *)startTime endTime:(NSString *)endTime {
    
    NSString *sql = @"";
    if ([startTime isEqualToString:@""] && ![endTime isEqualToString:@""]) {
        
        //  保存结束日期，则需要查询结束日期之前的记录 所有开始日期并按照逆序排列
        //  把查询出来的日期
        sql = [[NSString alloc] initWithFormat:@"SELECT * FROM period WHERE startTime <= '%@' order by startTime desc", endTime];
    }else if (![startTime isEqualToString:@""] && [endTime isEqualToString:@""]) {
        
        //  存在开始日期，则需要查询开始日期之后结束日期为空的记录 所有结束日期并按照顺序排列
        sql = [[NSString alloc] initWithFormat:@"SELECT * FROM period WHERE endTime >= '%@' order by endTime asc", startTime];
    }else {
        
        //  都存在择需要查询
        sql = [[NSString alloc] initWithFormat:@"SELECT * FROM period WHERE startTime == '%@' or endTime == '%@'", startTime, startTime];
    }
    
    FMResultSet *set = [_db executeQuery:sql];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    while (set.next) {
        
        NSDictionary *info = @{
                               @"id":@([set intForColumn:@"id"]),
                               @"startTime":[set stringForColumn:@"startTime"],
                               @"endTime":[set stringForColumn:@"endTime"]
                               };
        [infoArr addObject:info];
    }
    
    BOOL result;
    //  如果存在合适的查询结果，则把结果保存
    if (infoArr.count > 0) {
        
        NSDictionary *dict = infoArr[0];
        NSInteger recordId = [dict[@"id"] integerValue];
        
        BOOL insertFlag = FALSE;
        
        if (![startTime isEqualToString:@""] && [endTime isEqualToString:@""] && ![dict[@"endTime"] isEqualToString:@""]) {
            
            NSInteger interDays = [self pleaseInsertStarTimeo:startTime andInsertEndTime:dict[@"endTime"]];
            if (interDays >= 20) {
                insertFlag = YES;
            }
        }else if ([startTime isEqualToString:@""] && ![endTime isEqualToString:@""] && ![dict[@"startTime"] isEqualToString:@""]) {
            
            NSInteger interDays = [self pleaseInsertStarTimeo:dict[@"startTime"] andInsertEndTime:endTime];
            if (interDays >= 20) {
                insertFlag = YES;
            }
        }
        
        if (!insertFlag && ![dict[@"endTime"] isEqualToString:dict[@"startTime"]]) {
            
            //  如果不是开始结束时间相同，择需要重新赋值
            if ([startTime isEqualToString:@""]) {
                startTime = dict[@"startTime"];
            }
            if ([endTime isEqualToString:@""]) {
                endTime = dict[@"endTime"];
            }
        }
        
        if (insertFlag) {
            
            result = [_db executeUpdateWithFormat:@"INSERT INTO period(startTime, endTime) values (%@, %@)", startTime, endTime];
        }else {
            
            result = [_db executeUpdateWithFormat:@"UPDATE period SET startTime = %@, endTime = %@ WHERE id = %ld", startTime, endTime, recordId];
        }
    }else {
        result = [_db executeUpdateWithFormat:@"INSERT INTO period(startTime, endTime) values (%@, %@)", startTime, endTime];
    }
    
    [self addLog:@"增加记录" result:result];
    return result;
}

+ (NSInteger)pleaseInsertStarTimeo:(NSString *)time1 andInsertEndTime:(NSString *)time2{
    
    // 1.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy年MM月dd日";
    NSDate *date1 = [formatter dateFromString:time1];
    NSDate *date2 = [formatter dateFromString:time2];
    
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitDay;
    //  NSCalendarUnitYear | NSCalendarUnitMonth |
    
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    
    // 4.输出结果
    NSLog(@"两个时间相差%ld年%ld月%ld日", cmps.year, cmps.month, cmps.day);
    return cmps.day;
}

+ (NSArray *)queryPeriodWithMonth:(NSString *)month {
    
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM period WHERE startTime like '%@%%' or endTime like '%@%%'", month, month];
    
    FMResultSet *set = [_db executeQuery:sql];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    while (set.next) {
        
        NSDictionary *info = @{
                               @"id":@([set intForColumn:@"id"]),
                               @"startTime":[set stringForColumn:@"startTime"],
                               @"endTime":[set stringForColumn:@"endTime"]
                               };
        [infoArr addObject:info];
    }
    return infoArr;
}

+ (NSDictionary *)queryPeriodWithDay:(NSString *)day {
    
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM period WHERE startTime = '%@' or endTime = '%@'", day, day];
    
    FMResultSet *set = [_db executeQuery:sql];
    NSMutableArray *infoArr = [NSMutableArray array];
    
    while (set.next) {
        
        NSDictionary *info = @{
                               @"id":@([set intForColumn:@"id"]),
                               @"startTime":[set stringForColumn:@"startTime"],
                               @"endTime":[set stringForColumn:@"endTime"]
                               };
        [infoArr addObject:info];
    }
    return [infoArr firstObject];
}

+ (BOOL)deletePeriod:(NSString *)recordTime {
    
    BOOL result = [_db executeUpdateWithFormat:@"UPDATE period SET startTime = '' WHERE startTime == %@", recordTime];
    result = [_db executeUpdateWithFormat:@"UPDATE period SET endTime = '' WHERE endTime == %@", recordTime];
    result = [_db executeUpdateWithFormat:@"DELETE FROM period where startTime == '' and endTime == '' "];
    
    [self addLog:@"删除日期数据" result:result];
    return result;
}

//将color转为UIImage
+ (UIImage *)createImageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


//判断是什么格式
+ (BOOL) imageHasAlpha: (UIImage *) image {
    
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

//图片转换base64
+ (NSString *)base64ImageData: (UIImage *) image {
    
    NSData *imageData = nil;
    NSString *mimeType = nil;
    
    if ([self imageHasAlpha: image]) {
        imageData = UIImagePNGRepresentation(image);
        mimeType = @"image/png";
    } else {
        imageData = UIImageJPEGRepresentation(image, 0.09f);
        mimeType = @"image/jpg";
    }
    
    return [NSString stringWithFormat:@"data:%@;base64,%@", mimeType,
            [imageData base64EncodedStringWithOptions: NSDataBase64Encoding64CharacterLineLength]];
}


// 根据字符串，行间距，字体大小，最大宽度 获取label的高度
+ (CGFloat) heightWithStr:(NSString *)str lineSpacing:(CGFloat)lineSpacing fontSize:(CGFloat)size maxLabelWidth:(CGFloat)MaxLabelWidth{
    
    if (str==nil) return 25;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    if (lineSpacing != 0) {
        
        style.lineSpacing = lineSpacing;
        [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrStr.length)];
    }
    
    //    3.2. 计算文字的高度，根据 label 的宽最大度和行间距
    NSDictionary *dictonary = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:size],
                                NSParagraphStyleAttributeName : style
                                };
    
    CGFloat height = [str boundingRectWithSize:CGSizeMake(MaxLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictonary context:nil].size.height;
    return height;
}

// 根据字符串，行间距，字体大小，最大宽度 获取label的高度
+ (CGFloat)widthWithStr:(NSString *)str fontSize:(CGFloat)size {
    
    if (str==nil) return 25;
    
    //    3.2. 计算文字的高度，根据 label 的宽最大度和行间距
    NSDictionary *dictonary = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:size]
                                };
    
    CGFloat height = [str boundingRectWithSize:CGSizeMake(MAXFLOAT, SCREEN_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictonary context:nil].size.width;
    return height;
}

+ (CGFloat)heightWithStr:(NSString *)str firstLineHeadIndent:(CGFloat)firstLineHeadIndent headIndent:(CGFloat)headIndent lineSpacing:(CGFloat)lineSpacing fontSize:(CGFloat)size maxLabelWidth:(CGFloat)MaxLabelWidth {
    
    if (str==nil) return 25;
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    if (lineSpacing != 0) {
        style.firstLineHeadIndent = firstLineHeadIndent;
        style.headIndent = headIndent;
        style.lineSpacing = lineSpacing;
        style.alignment = NSTextAlignmentJustified;
        [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrStr.length)];
    }
    
    //    3.2. 计算文字的高度，根据 label 的宽最大度和行间距
    NSDictionary *dictonary = @{
                                NSFontAttributeName : [UIFont systemFontOfSize:size],
                                NSParagraphStyleAttributeName : style
                                };
    
    CGFloat height = [str boundingRectWithSize:CGSizeMake(MaxLabelWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dictonary context:nil].size.height;
    return height;
}


// Get IP Address
+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

/**
 * 判断手机号
 *
 */
+ (BOOL)validateMobileNumber:(NSString *)mobileNum {
    
    if ([mobileNum containsString:@"-"]) {
        mobileNum = [mobileNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    if ([mobileNum containsString:@" "]) {
        mobileNum = [mobileNum stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString *MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString *CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString *CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString *CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    
    /**
     *大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     *号码：七位或八位
     */
    NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES) || ([regextestcm evaluateWithObject:mobileNum] == YES) || ([regextestct evaluateWithObject:mobileNum] == YES) || ([regextestcu evaluateWithObject:mobileNum] == YES)|| ([regextestphs evaluateWithObject:mobileNum] == YES)) {
        
        return YES;
    }else {
        return NO;
    }
}

/**
 * 判断手机号
 *
 */
+ (BOOL)validatePhoneNumber:(NSString *)str {
    
    if ([str containsString:@"-"]) {
        str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    if ([str containsString:@" "]) {
        str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (str.length <11) return NO;
    NSString *phoneRegex = @"^1[34578]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:str];
}

/**
 *  判断验证码 *
 */
+ (BOOL)validateCodeNumber:(NSString *)code {
    
    NSString *CodeNumberRegex =@"^[A-Zz-z0-9]{4,6}+$";
    
    NSPredicate *CodeNumberpredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CodeNumberRegex];
    return [CodeNumberpredicate evaluateWithObject:code];
}


/**
 *  判断密码
 *
 */
+ (BOOL)validatePassword:(NSString *)passWord {
    
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    
    return [passWordPredicate evaluateWithObject:passWord];
}

/**
 *  判断用户名
 *
 */
+ (BOOL)validateUserName:(NSString *)name {
    
    NSString *userNameRegex =@"^[A-Zz-z0-9]{6,20}+$";
    
    NSPredicate *userNamepredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    return [userNamepredicate evaluateWithObject:name];
}



+ (BOOL) validateEmail:(NSString *)email
{
    NSString *emailRegex =@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

//验证年月日
+ (BOOL)validateWithDate:(NSString *)date {
    
    NSString *dateRegex= @"(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})-(((0[13578]|1[02])-(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)-(0[1-9]|[12][0-9]|30))|(02-(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))-02-29)";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", dateRegex];
    return [emailTest evaluateWithObject:date];
}

//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard {
    
    BOOL flag;
    
    if (identityCard.length < 18  ) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}

// 银行开户
+ (BOOL)validateBankCard: (NSString *)bankCard {
    
    NSString *regex2 = @"^([0-9]{16}|[0-9]{19})$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:bankCard];
    
    //    NSString *regex2 = @"^([0-9]{16}|[0-9]{19})$";
    //    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    //    return [identityCardPredicate evaluateWithObject:bankCard];
    
    //    if(bankCard.length==0)
    //    {
    //        return NO;
    //    }
    //    NSString *digitsOnly = @"";
    //    char c;
    //    for (int i = 0; i < bankCard.length; i++)
    //    {
    //        c = [bankCard characterAtIndex:i];
    //        if (isdigit(c))
    //        {
    //            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
    //        }
    //    }
    //    int sum = 0;
    //    int digit = 0;
    //    int addend = 0;
    //    BOOL timesTwo = false;
    //    for (NSint i = digitsOnly.length - 1; i >= 0; i--)
    //    {
    //        digit = [digitsOnly characterAtIndex:i] - '0';
    //        if (timesTwo)
    //        {
    //            addend = digit * 2;
    //            if (addend > 9) {
    //                addend -= 9;
    //            }
    //        }
    //        else {
    //            addend = digit;
    //        }
    //        sum += addend;
    //        timesTwo = !timesTwo;
    //    }
    //    int modulus = sum % 10;
    //    return modulus == 0;
}

//昵称
+ (BOOL)validateNickname:(NSString *)nickname {
    
    //国外人名字[u4e00-u9fa5]
    //[\u4E00-\u9FA5]{2,5}(?:·[\u4E00-\u9FA5]{2,5})*
    //     NSString *nicknameRegex = @"^[\u4e00-\u9fa5]{4,8}$";
    NSString *nicknameRegex = @"[\u4e00-\u9fa5]";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

+ (BOOL)isBlankString:(NSString *)string {
    
    if ([string isEqual:[NSNull null]]) {
        
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

+ (NSString *)numberStringWithString:(NSString *)string {
    
    NSString *result = [[string componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    return result;
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString {
    
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 毫秒值转化为秒
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString formatString:(NSString *)formatString {
    
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"beijing"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:formatString];
    
    // 毫秒值转化为秒
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timeString doubleValue]/ 1000.0];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

// 改变图片尺寸
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize {
    
    UIImage *newimage;
    
    if (nil == image) {
        newimage = nil;
        
    } else {
        CGSize oldsize = image.size;
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height) {
            
            rect.size.width = asize.width;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y =0;
            
        } else{
            rect.size.width = asize.width;
            rect.size.height = asize.height;
            rect.origin.x =0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context =UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0,0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;
}



+ (NSString *)deviceVersion {
    
    // 需要#import "sys/utsname.h"
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //iPhone
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    return deviceString;
}

#pragma mark - 获取设备当前网络IP地址
+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    // YJLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}


#pragma mark - 获取设备外网IP地址
+(NSDictionary *)deviceWANIPAdress
{
    
    NSError *error;
    
    NSURL *ipURL = [NSURL URLWithString:@"http://pv.sohu.com/cityjson?ie=utf-8"];
    
    NSMutableString *ip = [NSMutableString stringWithContentsOfURL:ipURL encoding:NSUTF8StringEncoding error:&error];
    
    //判断返回字符串是否为所需数据
    
    if ([ip hasPrefix:@"var returnCitySN = "])
        
    {
        
        //对字符串进行处理，然后进行json解析
        
        //删除字符串多余字符串
        
        NSRange range = NSMakeRange(0, 19);
        
        [ip deleteCharactersInRange:range];
        
        NSString * nowIp =[ip substringToIndex:ip.length-1];
        
        //将字符串转换成二进制进行Json解析
        
        NSData * data = [nowIp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        return dict;
        
    }
    
    return nil;
    
}

+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            //            NSRange resultRange = [firstMatch rangeAtIndex:0];
            //            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            //YJLog(@"%@",result);
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses {
    
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (NSString *)getTypeNameWithType:(NSInteger)type {
    
    NSString *typeName = [NSString stringWithFormat:@"C%ld", type];
    
    if(type > 2 && type <= 4){
        
        typeName = [NSString stringWithFormat:@"B%ld", type - 2];
        
    }else if(type > 4){
        
        typeName = [NSString stringWithFormat:@"A%ld", type - 4];
    }
    return typeName;
}



+(UIImage *)drawOvalWithImage:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)borderColor{
    
    //设置边框宽度
    
    CGFloat imageWH = image.size.width;
    
    //计算外圆的尺寸
    
    CGFloat ovalWH = imageWH + 2 * border;
    
    //开启上下文
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ovalWH, ovalWH), NO, 0);
    
    //画一个大的圆形
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, ovalWH, ovalWH)];
    
    [borderColor set];
    
    [path fill];
    
    //设置裁剪区域
    
    UIBezierPath *path1 = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(border, border, imageWH, imageWH)];
    
    [path1 addClip];
    
    //绘制图片
    
    [image drawAtPoint:CGPointMake(border, border)];
    
    //从上下文中获取图片
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

+ (CAShapeLayer *)drawRoundWidgetWith:(CGRect)rect corderRadius:(CGFloat)radius{
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = rect;
    maskLayer.path = maskPath.CGPath;
    
    return maskLayer;
}


- (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size{
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
    
}

+(void)setAudioToolBoxWith:(NSString *)musicName and:(NSString *)musicType{
    
    NSBundle * bundle = [NSBundle mainBundle];
    NSString * path = [bundle pathForResource:musicName ofType:musicType];
    NSURL * url = [NSURL URLWithString:path];
    
    SystemSoundID soundID = 0;
    // 将URL所在的音频文件注册为系统声音,soundID音频ID标示该音频
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &soundID);
    
    //播放音频
    AudioServicesPlaySystemSound(soundID);
    
    //播放系统震动
    //AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
    //声音销毁
    AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
        NSLog(@"播放完成");
    });
    
}

+ (NSMutableArray *)resolutionGitImage{
    NSString * path = [[NSBundle mainBundle]pathForResource:@"xiaoqic" ofType:@"gif"];
    NSData * imageData = [NSData dataWithContentsOfFile:path];
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)imageData, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    
    return frames;
}
@end
