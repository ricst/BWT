//
//  BWTFirstViewController.h
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWTFirstViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSDate *startTime;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (strong, nonatomic) NSURLConnection *connection;

// Connections to read and write URL text field
@property (weak, nonatomic) IBOutlet UITextField *URLText;
- (IBAction)URLTextAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity1;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;

- (IBAction)startDownload:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *bytesDownloaded;
@property (weak, nonatomic) IBOutlet UITextField *elapsedTime;
@property (weak, nonatomic) IBOutlet UITextField *downloadRate;

@end
