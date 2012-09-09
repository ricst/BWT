//
//  MyDownloader.h
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/8/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved

// Borrowed from Matt Neuburg, Programming iOS 5, O'Reilly, 2nd Ed. p918

#import <Foundation/Foundation.h>

#define CONNECTION_FINISHED @"connectionFinished"

@interface MyDownloader : NSObject

@property (nonatomic, strong, readonly) NSURLConnection *connection;
@property (nonatomic, strong, readonly) NSData *receivedData;
@property (nonatomic, readonly) NSInteger downloadID;

- (id)initWithRequest:(NSURLRequest *)req;
- (id)initWithRequest:(NSURLRequest *)req dloadID:(NSInteger)downloadID;

@end
