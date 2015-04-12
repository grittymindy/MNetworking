//
//  MNHTTPOperation.m
//  
//
//  Created by Mindy on 14-8-14.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import "MNHTTPOperation.h"

@interface MNHTTPOperation()

@property (nonatomic, strong) NSMutableDictionary *postValues;

@property (nonatomic, strong) NSMutableDictionary *postFilePaths;

@property (nonatomic, strong) NSMutableDictionary *postData;

@end

@implementation MNHTTPOperation

+(id)operation{
    return [[self alloc] init];
}

-(id)init{
    if(self = [super init]){
        self.stringEncoding = NSUTF8StringEncoding;
    }
    
    return self;
}

-(void)addPostValue:(id<NSObject>)value forKey:(NSString *)key{
    if(!value || !key){
        return;
    }
    
    if(!self.postValues){
        self.postValues  = [NSMutableDictionary dictionary];
    }
    
    [self.postValues setObject:value forKey:key];
}


-(NSDictionary *)allPostValues{
    return [self.postValues copy];
}

-(void)addPostFilePath:(NSString *)filePath forKey:(NSString *)key{
    if(!filePath || !key){
        return;
    }
    
    if(!self.postValues){
        self.postValues  = [NSMutableDictionary dictionary];
    }
    
    [self.postValues setObject:filePath forKey:key];
}

-(NSDictionary*)allPostFilePaths{
    return [self.postFilePaths copy];
}

-(void)addPostData:(NSData *)data forKey:(NSString *)key{
    if(!data || !key){
        return;
    }
    
    if(!self.postValues){
        self.postValues  = [NSMutableDictionary dictionary];
    }
    
    [self.postValues setObject:data forKey:key];
}

-(NSDictionary *)allPostData{
    return  [self.postData copy];
}

@end
