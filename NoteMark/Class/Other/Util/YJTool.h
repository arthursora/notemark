//
//  YJTool.h
//  NoteMark
//
//  Created by 朱亚杰 on 2018/1/5.
//  Copyright © 2018年 朱亚杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetModel.h"

@interface YJTool : NSObject

+ (void)initialize;

#pragma mark 添加记录
+ (BOOL)addTarget:(TargetModel *)target;

#pragma mark 删除记录
+ (BOOL)deleteTarget:(NSInteger)targetId;

#pragma mark 查询记录列表
+ (NSMutableArray *)queryTargets;

#pragma mark 添加记录
+ (BOOL)addLucky:(NSString *)text image:(NSData *)image;

#pragma mark 删除记录
+ (BOOL)deleteLucky:(NSInteger)luckyId;

#pragma mark 查询记录列表
+ (NSMutableArray *)queryLuckies;

#pragma mark 添加记录
+ (BOOL)addPeriod:(NSString *)startTime endTime:(NSString *)endTime;

#pragma mark 查询记录列表
+ (NSArray *)queryPeriodWithMonth:(NSString *)month;

#pragma mark 查询记录列表
+ (NSDictionary *)queryPeriodWithDay:(NSString *)day;

#pragma mark 删除记录
+ (BOOL)deletePeriod:(NSString *)recordTime;


//  颜色转成图片
+ (UIImage *)createImageWithColor:(UIColor *)color;

//判断是什么格式
+ (BOOL) imageHasAlpha: (UIImage *) image;
//改变图片尺寸
+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;

//图片转换base64
+ (NSString *)base64ImageData: (UIImage *) image;

// 根据字符串，行间距，字体大小，最大宽度 获取label的高度
+ (CGFloat) heightWithStr:(NSString *)str lineSpacing:(CGFloat)lineSpacing fontSize:(CGFloat)size maxLabelWidth:(CGFloat)MaxLabelWidth;

+ (CGFloat)widthWithStr:(NSString *)str fontSize:(CGFloat)size;

// 根据字符串，首行缩进，行间距，字体大小，最大宽度 获取label的高度
+ (CGFloat) heightWithStr:(NSString *)str firstLineHeadIndent:(CGFloat)firstLineHeadIndent headIndent:(CGFloat)headIndent lineSpacing:(CGFloat)lineSpacing fontSize:(CGFloat)size maxLabelWidth:(CGFloat)MaxLabelWidth;

//获取ip
+ (NSString *)getIPAddress;
//获取外网IP
+(NSDictionary *)deviceWANIPAdress;

/**
 * 判断手机号
 */
+ (BOOL)validatePhoneNumber:(NSString *)str;


/**
 * 判断座机号码
 */
+ (BOOL)validateMobileNumber:(NSString *)mobileNum;

/**
 *  判断验证码
 */
+ (BOOL)validateCodeNumber:(NSString *)code;

/**
 *  判断密码
 */
+ (BOOL)validatePassword:(NSString *)passWord;

/**
 *  判断用户名
 */
+ (BOOL)validateUserName:(NSString *)name;

//邮箱验证
+(BOOL)validateEmail:(NSString *)email;

//验证年月日
+ (BOOL)validateWithDate:(NSString *)date;

//昵称
+ (BOOL)validateNickname:(NSString *)nickname;

//身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard;

// 银行开户
+ (BOOL)validateBankCard: (NSString *)bankCard;

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString;

+ (NSString *)timeWithTimeIntervalString:(NSString *)timeString formatString:(NSString *)formatString;

// 判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string;

//  返回只有数字的字符串
+ (NSString *)numberStringWithString:(NSString *)string;

//获取手机型号
+ (NSString *)deviceVersion;

//获取ip新方法
+ (NSString *)getIPAddress:(BOOL)preferIPv4;

+ (NSString *)getTypeNameWithType:(NSInteger)type;

/* 把图片剪切成圆形的图片 */
+ (UIImage *)drawOvalWithImage:(UIImage *)image borderWidth:(CGFloat)border borderColor:(UIColor *)borderColor;

+ (CAShapeLayer *)drawRoundWidgetWith:(CGRect)rect corderRadius:(CGFloat)radius;

/* 生成带渐变色效果的image */
//+ (UIImage *)makeImageWithView:(UIView *)view withSize:(CGSize)size;

+(void)setAudioToolBoxWith:(NSString *)musicName and:(NSString *)musicType;

//解析git图片
+ (NSMutableArray *)resolutionGitImage;
@end
