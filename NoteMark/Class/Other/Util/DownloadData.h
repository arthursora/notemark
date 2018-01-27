//
//  DownloadData.h
//  YuanCheng
//
//  Created by dongshangtong on 16/3/14.
//  Copyright © 2016年 dongshangtong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface DownloadData : NSObject


+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;

+ (AFSecurityPolicy *)securePolicy;

@end
