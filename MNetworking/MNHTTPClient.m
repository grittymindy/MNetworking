//
//  MNHTTPClient.m
//  
//
//  Created by Mindy on 14-8-14.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import "MNHTTPClient.h"
#import "M_ASIHTTPRequest.h"
#import "M_ASIHTTPRequest+MNetworking.h"
#import "M_ASIFormDataRequest.h"
#import "M_ASIDownloadCache.h"



static dispatch_queue_t json_processing_queue() {
    static dispatch_queue_t json_processing_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        json_processing_queue = dispatch_queue_create("com.mnetworking.json_processing_processing", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return json_processing_queue;
}

static NSURL* URLFromURLStr(NSString *urlStr){
    NSURL *url = nil;
    if (urlStr && urlStr.length) {
        url = [NSURL URLWithString:urlStr];
        if (!url) {
            NSString *_urlString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_urlString && _urlString.length) {
                url = [NSURL URLWithString:_urlString];
            }
            if (!url) {
                _urlString = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                _urlString = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (_urlString && _urlString.length) {
                    url = [NSURL URLWithString:_urlString];
                }
            }
        }
    }
    return url;
}


@interface MNHTTPClient()<M_ASIHTTPRequestDelegate>

@property (readwrite, nonatomic, strong) NSString *baseURLStr;

@end


@implementation MNHTTPClient 

+ (instancetype)clientWithBaseURLStr:(NSString *)urlStr{
    return [[[self class] alloc] initWithBaseURLStr:urlStr];
}


- (id)initWithBaseURLStr:(NSString *)urlStr{
    if(self = [super init]){        
        self.baseURLStr = urlStr;
    }
    
    return self;
}

-(void)GETOperation:(MNHTTPOperation *)operation{
    NSURL *url = [self URLFromOperation:operation];
    M_ASIHTTPRequest *request = [M_ASIHTTPRequest requestWithURL:url];
    [self buildRequest:request fromOperation:operation];
    [request startAsynchronous];
}

-(void)POSTOperation:(MNHTTPOperation *)operation{
    NSURL *url = [self URLFromOperation:operation];
    M_ASIFormDataRequest *request = [M_ASIFormDataRequest requestWithURL:url];
    [self buildRequest:request fromOperation:operation];
    [request startAsynchronous];
}


#pragma mark - Cancel HTTPOperation
-(void)cancelOperation:(MNHTTPOperation*)operation{
    NSOperationQueue *queue = [M_ASIHTTPRequest sharedQueue];
    for(M_ASIHTTPRequest *request in queue.operations){
        if([request.operation isEqual:operation]){
            [request clearDelegatesAndCancel];
        }
    }
}

-(void)cancelGroup:(NSString *)groupName{
    NSOperationQueue *queue = [M_ASIHTTPRequest sharedQueue];
    for(M_ASIHTTPRequest *request in queue.operations){
        if([request.groupName isEqualToString:groupName]){
            [request clearDelegatesAndCancel];
        }
    }
}

-(void)cancelAllOperations{
    NSOperationQueue *queue = [M_ASIHTTPRequest sharedQueue];
    for(M_ASIHTTPRequest *request in queue.operations){
        [request clearDelegatesAndCancel];
    }
}

#pragma mark - Query
-(BOOL)existsGroup:(NSString *)groupName{
    NSOperationQueue *queue = [M_ASIHTTPRequest sharedQueue];
    for(M_ASIHTTPRequest *request in queue.operations){
        if([request.groupName isEqualToString:groupName]){
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Private
-(void)buildRequest:(M_ASIHTTPRequest *)request fromOperation:(MNHTTPOperation *)operation{
    [self buildBasicPartForRequest:request fromOperation:operation];

    [self buildBlockPartForRequest:request fromOperation:operation];
    
    [self buildPostPartForRequest:request fromOperation:operation];
}


-(void)buildBasicPartForRequest:(M_ASIHTTPRequest *)request fromOperation:(MNHTTPOperation *)operation{
    NSURL *url = [self URLFromOperation:operation];
    request.url = url;
    request.groupName = operation.groupName;
    request.operation = operation;
    request.timeOutSeconds = 60;
    [request setDownloadCache:[M_ASIDownloadCache sharedCache]];
    
    if(operation.shouldUseCache){
        request.cachePolicy = (M_ASICachePolicy)(M_ASIAskServerIfModifiedWhenStaleCachePolicy | M_ASIFallbackToCacheIfLoadFailsCachePolicy);
        request.cacheStoragePolicy = M_ASICachePermanentlyCacheStoragePolicy;
        request.secondsToCache = operation.secondsToCache;
    }else{
        request.cachePolicy = M_ASIDoNotWriteToCacheCachePolicy;
        request.cacheStoragePolicy = M_ASICacheForSessionDurationCacheStoragePolicy;
        request.secondsToCache = 0;
    }
    
    if(self.userAgentStr){
        request.userAgentString = self.userAgentStr;
    }
}

-(void)buildBlockPartForRequest:(M_ASIHTTPRequest *)request fromOperation:(MNHTTPOperation *)operation{
    __weak typeof(&*request) weakReq = request;
    
    /**
     坑三：当block中又有dispatch_async的时候，要特别注意将weakReq retain以下（__strong)， 防止block执行过程中weakReq被释放掉
     */
    ASIBasicBlock completionBlock = ^{  //ALWAYS CALLED ON MAIN THREAD
        __strong typeof(&*weakReq) strongReq = weakReq;
        if(!strongReq){
            return;
        }
        //        DLog(@"weakReq: %@", weakReq);
        dispatch_async(json_processing_queue(), ^{
            id json = nil;
            //            DLog(@"weakReq: %@", weakReq);
            if(strongReq.responseData.length){
                json = [NSJSONSerialization JSONObjectWithData:strongReq.responseData options:NSJSONReadingMutableContainers error:NULL];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //                DLog(@"weakReq: %@", weakReq);
                if(strongReq.operation.success){
                    strongReq.operation.success(json);
                }
            });
        });
    };
    
    [request setCompletionBlock:completionBlock];
    
    /**
     坑二： ASIHTTPRequest的completioBlock和failedBlock永远是在主线程回调的
     */
    ASIBasicBlock failedBlock  = ^{  //ALWAYS CALLED ON MAIN THREAD
        __strong typeof(&*weakReq) strongReq = weakReq;
        if(!strongReq){
            return;
        }
        if(strongReq.operation.failure){
            strongReq.operation.failure(strongReq.error);
        }
    };
    
    [request setFailedBlock:failedBlock];
}


-(void)buildPostPartForRequest:(M_ASIHTTPRequest *)request fromOperation:(MNHTTPOperation *)operation{
    if([request isKindOfClass:[M_ASIFormDataRequest class]]){
        NSDictionary *postValues = [operation allPostValues];
        NSDictionary *postFilePaths = [operation allPostFilePaths];
        NSDictionary *postData = [operation allPostData];
        
        
        typedef void(^ProcessEach)(NSString *key, id object);
        
        void(^Process)(NSDictionary *dict, ProcessEach block) = ^(NSDictionary *dict, ProcessEach block){
            if(!dict){
                return;
            }
            NSArray *allKeys = [dict allKeys];
            for(NSString *key in allKeys){
                id object = [dict objectForKey:key];
                block(key, object);
            }
        };
        
        ProcessEach processValues = ^(NSString *key, id object){
            [(M_ASIFormDataRequest *)request addPostValue:object forKey:key];
        };
        Process(postValues, processValues);
        
        ProcessEach processFilePaths = ^(NSString *key, id object){
            [(M_ASIFormDataRequest *)request addFile:object forKey:key];
        };
        Process(postFilePaths, processFilePaths);
        
        ProcessEach processData = ^(NSString *key, id object){
            [(M_ASIFormDataRequest *)request addData:object forKey:key];
        };
        Process(postData, processData);
        
        ((M_ASIFormDataRequest *)request).stringEncoding = operation.stringEncoding;
    }
}


-(NSString *)URLStrFromOperation:(MNHTTPOperation *)operation{
    /**
     坑一: 以下两个urlStr是不同的
     [self.baseURLStr stringByAppendingPathComponent:operation.path]
     [NSString stringWithFormat:@"%@%@", self.baseURLStr, operation.path]
     */
    NSString *urlStr = [NSString stringWithFormat:@"%@%@%@", self.baseURLStr, operation.path, self.appendedURLStr];
    
    return urlStr;
}



-(NSURL *)URLFromOperation:(MNHTTPOperation *)operation{
    NSString *urlStr = [self URLStrFromOperation:operation];
    
    NSURL *url = URLFromURLStr(urlStr);
    
    return url;
}

@end
