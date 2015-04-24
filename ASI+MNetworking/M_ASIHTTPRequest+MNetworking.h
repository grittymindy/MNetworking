//
//  ASIHTTPRequest+HTTPOperation.h
//  
//
//  Created by Mindy on 14-8-15.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import "M_ASIHTTPRequest.h"
#import "MNHTTPOperation.h"

@interface M_ASIHTTPRequest (MNetworking)

@property (nonatomic, strong) NSString *groupName;

@property (nonatomic, strong) MNHTTPOperation *operation;

@end
