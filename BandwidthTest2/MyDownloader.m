//
//  MyDownloader.m
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/8/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import "MyDownloader.h"

//Private properties
@interface MyDownloader ()

@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, copy) NSURLRequest *request;
@property (nonatomic, strong) NSMutableData *mutableReceivedData;
@property (nonatomic) NSInteger downloadID;

@end

@implementation MyDownloader

@synthesize connection = _connection;
@synthesize request = _request;
@synthesize mutableReceivedData = _mutableReceivedData;
@synthesize downloadID = _downloadID;

- (NSData *)receivedData {
    return [self.mutableReceivedData copy];
}

- (NSInteger)downloadID {
    return self->_downloadID;
}

// Override NSURLConnection method; use deep copy
- (id)initWithRequest:(NSURLRequest *)req {
    self = [super init];
    if (self) {
        self->_request = [req copy];
        self->_connection = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
        self->_mutableReceivedData = [[NSMutableData alloc] init];
    }
    return self;
}

// Provides an optional approach to later identify a connection by a user-supplied string
- (id)initWithRequest:(NSURLRequest *)req dloadID:(NSInteger)downloadID {
    self->_downloadID = downloadID;
    return [self initWithRequest:req];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.mutableReceivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mutableReceivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_FINISHED object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:CONNECTION_FINISHED object:self];
}

@end
