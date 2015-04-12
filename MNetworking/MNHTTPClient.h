//
//  MNHTTPClient.h
//
//  Created by Mindy on 14-8-14.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//
//

/**
 ** TODO: 
 ** 1. add other methods besides GET and POST
 ** 2. add synchronous request support
 ** 3. others
 */

#import <Foundation/Foundation.h>
#import "MNHTTPOperation.h"

@interface MNHTTPClient : NSObject

@property (readonly, nonatomic, strong) NSString *baseURLStr;

@property (nonatomic, strong) NSString *appendedURLStr;

@property (nonatomic, strong) NSString *userAgentStr;


#pragma mark - Creating And Initializing HTTP Clients
+ (instancetype)clientWithBaseURLStr:(NSString  *)baseURLStr;

- (id)initWithBaseURLStr:(NSString *)baseURLStr;


#pragma mark - Start HTTPOperation
-(void)GETOperation:(MNHTTPOperation *)operation;

-(void)POSTOperation:(MNHTTPOperation *)operation;

#pragma mark - Cancel HTTPOperation
-(void)cancelOperation:(MNHTTPOperation*)operation;

-(void)cancelGroup:(NSString *)groupName;

-(void)cancelAllOperations;

#pragma mark - Query HTTPOperation

-(BOOL)existsGroup:(NSString *)groupName;

@end
