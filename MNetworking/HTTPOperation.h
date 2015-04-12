//
//  HTTPOperation.h
//
//
//  Created by Mindy on 14-8-14.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 HTTOperatoin是对HTTP请求的描述信息.
 */

#define CACHE_TIME_TEN_SECONDS  10
#define CACHE_TIME_HALF_AN_HOUR 30 * 60
#define CACHE_TIME_AN_HOUR      1 * 60 * 60
#define CACHE_TIME_AN_MONTH     30 * 24 * 60 * 60

@class HTTPOperation;

typedef void (^HTTPSuccessBlock)(id responseObject);

typedef void (^HTTPFailureBlock)(NSError *error);


@interface HTTPOperation : NSObject

@property (nonatomic, copy) NSString *path;                     //路径

@property (nonatomic, assign) BOOL  shouldUseCache;             //是否使用缓存

@property (nonatomic, assign) NSTimeInterval secondsToCache;  //缓存有效时间

@property (nonatomic, copy) HTTPSuccessBlock success;         //成功的回调

@property (nonatomic, copy) HTTPFailureBlock failure;         //失败的回调

@property (nonatomic, strong) NSString *groupName;


+(id)operation;


//for POST operation only!!

@property (nonatomic, assign) NSStringEncoding stringEncoding;

-(void)addPostValue:(id<NSObject>)value forKey:(NSString *)key;

-(NSDictionary *)allPostValues;

-(void)addPostFilePath:(NSString *)filePath forKey:(NSString *)key;

-(NSDictionary *)allPostFilePaths;

-(void)addPostData:(NSData *)data forKey:(NSString *)key;

-(NSDictionary *)allPostData;

@end
