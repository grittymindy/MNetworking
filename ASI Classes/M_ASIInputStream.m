//
//  ASIInputStream.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 10/08/2009.
//  Copyright 2009 All-Seeing Interactive. All rights reserved.
//

#import "M_ASIInputStream.h"
#import "M_ASIHTTPRequest.h"

// Used to ensure only one request can read data at once
static NSLock *readLock = nil;

@implementation M_ASIInputStream

+ (void)initialize
{
	if (self == [M_ASIInputStream class]) {
		readLock = [[NSLock alloc] init];
	}
}

+ (id)inputStreamWithFileAtPath:(NSString *)path request:(M_ASIHTTPRequest *)theRequest
{
	M_ASIInputStream *theStream = [[[self alloc] init] autorelease];
	[theStream setRequest:theRequest];
	[theStream setStream:[NSInputStream inputStreamWithFileAtPath:path]];
	return theStream;
}

+ (id)inputStreamWithData:(NSData *)data request:(M_ASIHTTPRequest *)theRequest
{
	M_ASIInputStream *theStream = [[[self alloc] init] autorelease];
	[theStream setRequest:theRequest];
	[theStream setStream:[NSInputStream inputStreamWithData:data]];
	return theStream;
}

- (void)dealloc
{
	[stream release];
	[super dealloc];
}

// Called when CFNetwork wants to read more of our request body
// When throttling is on, we ask ASIHTTPRequest for the maximum amount of data we can read
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	[readLock lock];
	unsigned long toRead = len;
	if ([M_ASIHTTPRequest isBandwidthThrottled]) {
		toRead = [M_ASIHTTPRequest maxUploadReadLength];
		if (toRead > len) {
			toRead = len;
		} else if (toRead == 0) {
			toRead = 1;
		}
		[request performThrottling];
	}
	[readLock unlock];
	NSInteger rv = [stream read:buffer maxLength:toRead];
	if (rv > 0)
		[M_ASIHTTPRequest incrementBandwidthUsedInLastSecond:(NSUInteger)rv];
	return rv;
}

/*
 * Implement NSInputStream mandatory methods to make sure they are implemented
 * (necessary for MacRuby for example) and avoid the overhead of method
 * forwarding for these common methods.
 */
- (void)open
{
    [stream open];
}

- (void)close
{
    [stream close];
}

- (id)delegate
{
    return [stream delegate];
}

- (void)setDelegate:(id)delegate
{
    [stream setDelegate:delegate];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
    [stream removeFromRunLoop:aRunLoop forMode:mode];
}

- (id)propertyForKey:(NSString *)key
{
    return [stream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
    return [stream setProperty:property forKey:key];
}

- (NSStreamStatus)streamStatus
{
    return [stream streamStatus];
}

- (NSError *)streamError
{
    return [stream streamError];
}

// If we get asked to perform a method we don't have (probably internal ones),
// we'll just forward the message to our stream

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [stream methodSignatureForSelector:aSelector];
}
	 
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:stream];
}

@synthesize stream;
@synthesize request;
@end
