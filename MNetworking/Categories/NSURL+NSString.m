//
//  NSURL+NSString.m
//
//
//  Created by Mindy on 14-8-27.
//  Copyright (c) 2014年 Mindy. All rights reserved.
//

#import "NSURL+NSString.h"
#import "MethodSwizzling.h"

@implementation NSURL (NSString)

+(void)load{
    SwizzleClassMethods(self, @selector(validURLWithString:), @selector(URLWithString:));
}

+(NSURL *)validURLWithString:(NSString *)urlString{
    NSURL *url = nil;
    if (urlString && urlString.length) {
        url = [NSURL validURLWithString:urlString];
        if (!url) {
            NSString *_urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (_urlString && _urlString.length) {
                url = [NSURL validURLWithString:_urlString];
            }
            if (!url) {
                _urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                _urlString = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                if (_urlString && _urlString.length) {
                    url = [NSURL validURLWithString:_urlString];
                }
            }
        }
    }
    return url;
}

@end
