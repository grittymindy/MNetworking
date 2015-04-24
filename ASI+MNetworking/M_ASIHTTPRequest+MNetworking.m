//
//  ASIHTTPRequest+HTTPOperation.m
//  
//
//  Created by Mindy on 14-8-15.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import "M_ASIHTTPRequest+MNetworking.h"
#import <objc/runtime.h>


static const char *groupNameKey;
static const char *operationKey;

@implementation M_ASIHTTPRequest (MNetworking)


-(NSString *)groupName{
    return objc_getAssociatedObject(self, &groupNameKey);
}


-(void)setGroupName:(NSString *)groupName{
    objc_setAssociatedObject(self, &groupNameKey, groupName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(MNHTTPOperation *)operation{
   return objc_getAssociatedObject(self, &operationKey);
}


-(void)setOperation:(MNHTTPOperation *)operation{
    objc_setAssociatedObject(self, &operationKey, operation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
