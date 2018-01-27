 //
//  DownloadData.m
//  YuanCheng
//
//  Created by dongshangtong on 16/3/14.
//  Copyright © 2016年 dongshangtong. All rights reserved.
//

#import "DownloadData.h"

@interface DownloadData();


@end


@implementation DownloadData


/**
 *  get 请求
 *
 *  @param url  请求路径
 *  @param params  请求参数
 *  @param success  成功
 *  @param failure 请求错误
 */

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    //  开发
//    if (APP_DISTRIBUTION_APPSTORE != 1) {
//
//        mgr.securityPolicy = [self securePolicy];
//    }
    
    if(!params) {
        params = [NSDictionary dictionary];
    }
    
    //  requestType 必传参数
    NSMutableDictionary *mutaParams = [params mutableCopy];
    [mutaParams setObject:@"c2V0NTma8+I=" forKey:@"requestType"];
    
    //  userId，token 登录之后再传的参数
    //  添加 拦截需要的请求参数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId) {
        
        NSString *token = [userDefaults objectForKey:@"token"];
        [mutaParams setObject:token forKey:@"token"];
        [mutaParams setObject:userId forKey:@"appUserId"];
    }
    
    [mgr GET:url parameters:[mutaParams copy] progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            success(responseObject);
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSString *errorStr = error.localizedDescription;
        NSString *errorCode = [errorStr substringWithRange:NSMakeRange(errorStr.length - 4, 3 )];
        //  如果失败码为401 则不现实失败弹出框
        if (![errorCode isEqualToString:@"401"]) {
            
            if(![errorStr containsString:@"似乎已断开与互联网的连接"]){
                
                [[UIApplication sharedApplication].keyWindow presentFailureTips:@"网络请求失败"];
            }
        }
        if (failure) {
            failure(error);
        }
        YJLog(@"网络请求有错误:%@",errorStr);
    }];
}

/**
 *  post 请求
 *
 *  @param url  请求路径
 *  @param params  请求参数
 *  @param success  成功
 *  @param failure 请求错误
 */
+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure {
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
    
//    if (APP_DISTRIBUTION_APPSTORE != 1) {
//
//        mgr.securityPolicy = [self securePolicy];
//    }
    
    if(!params) {
        params = [NSDictionary dictionary];
    }
    //  requestType 必传参数
    NSMutableDictionary *mutaParams = [params mutableCopy];
    [mutaParams setObject:@"c2V0NTma8+I=" forKey:@"requestType"];
    
    //  userId，token 登录之后再传的参数
    //  添加 拦截需要的请求参数
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:@"userId"];
    if (userId) {
        
        NSString *token = [userDefaults objectForKey:@"token"];
        [mutaParams setObject:token forKey:@"token"];
        [mutaParams setObject:userId forKey:@"appUserId"];
    }
    
    [mgr POST:url parameters:[mutaParams copy] progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        if (failure) {
            failure(error);
        }
        
        //  如果失败码为401 则不现实失败弹出框
        NSString *errorStr = error.localizedDescription;
        NSString *errorCode = [errorStr substringWithRange:NSMakeRange(errorStr.length - 4, 3 )];
        
        if (![errorCode isEqualToString:@"401"]) {
            
            if(![errorStr containsString:@"似乎已断开与互联网的连接"]){
                
                [[UIApplication sharedApplication].keyWindow presentFailureTips:@"网络请求失败"];
            }
        }
        YJLog(@"网络请求有错误:%@",error.localizedDescription);
    }];
}

+ (AFSecurityPolicy *)securePolicy {
    
    /**
    1-正式
    2-开发: 9000
    0-测试: 8080
     */
    NSString *cerPath = @"";
//    if (APP_DISTRIBUTION_APPSTORE == 2) {
//        
//        cerPath = [[NSBundle mainBundle] pathForResource:@"decer" ofType:@"cer"];
//    }else if (APP_DISTRIBUTION_APPSTORE == 0) {
//        cerPath = [[NSBundle mainBundle] pathForResource:@"testcer" ofType:@"cer"];
//    }
    
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    NSSet *cerSet = [NSSet setWithObjects:cerData, nil];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    [securityPolicy setPinnedCertificates:cerSet];
    return securityPolicy;
}

@end
