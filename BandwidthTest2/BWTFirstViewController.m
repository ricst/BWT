//
//  BWTFirstViewController.m
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import "BWTFirstViewController.h"

// 0 => enable debug logging. 1=> Disable debug logging
#define MyLog if(0); else NSLog

// Maybe allow user to adjust
#define DOWNLOAD_TIMEOUT 15.0f

@interface BWTFirstViewController ()

@end

@implementation BWTFirstViewController

@synthesize startTime = _startTime;
@synthesize receivedData = _receivedData;
@synthesize connection = _connection;

@synthesize bytesDownloaded;
@synthesize elapsedTime;
@synthesize downloadRate;
@synthesize myWebView;
@synthesize activity1;
@synthesize activity2;
@synthesize URLText;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Single", @"Single");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.myWebView.delegate = self;
    
    // Start with an initial web page loaded
    NSString *initialURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"INITIAL_WEBSITE"];
    NSURL *url = [NSURL URLWithString:initialURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:request];
    
    // Set a few other properties
    self.bytesDownloaded.textColor = [UIColor blueColor];
    self.elapsedTime.textColor = [UIColor blueColor];
    self.downloadRate.textColor = [UIColor blueColor];
}

- (void)viewDidUnload
{
    [self setURLText:nil];
    [self setMyWebView:nil];
    [self setActivity1:nil];
    [self setActivity2:nil];
    [self setBytesDownloaded:nil];
    [self setElapsedTime:nil];
    [self setDownloadRate:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

// Portrait only, for now
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Text field for URL entry
- (IBAction)URLTextAction:(id)sender {
    
    NSString *urlText = [NSString stringWithString:self.URLText.text];
    MyLog(@"User entered: %@", urlText);
    
    // Add http:// prefix if not present
    if (![urlText hasPrefix:@"http"]) {
        urlText = [@"http://" stringByAppendingString:urlText];
    }
    
    MyLog(@"URL text now = %@", urlText);
    
    NSURL *url = [NSURL URLWithString:urlText];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.myWebView loadRequest:request];
}

// Start button for bandwidth test
- (IBAction)startDownload:(id)sender {
    
    self.receivedData = [NSMutableData data];
    NSURL *url = [self.myWebView.request URL];
    NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:DOWNLOAD_TIMEOUT];
    
    [self.activity2 startAnimating];
    self.startTime = [NSDate date];
    
    self.connection = [NSURLConnection connectionWithRequest:req delegate:self];
}

#pragma mark NSURLConnectionDataDelegate methods

// Connection starting - clear buffer
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [self.receivedData setLength:0];
}

// Data arriving - add it to the receive buffer
- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [self.receivedData appendData:data];
}

// Error - Clean up
- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    [self.receivedData setLength:0];
    
    // Indicate Error on interface ****
    self.bytesDownloaded.text = @"Error";
    self.elapsedTime.text = @"0.0";
    self.downloadRate.text = @"0";
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSUInteger bytesReceived = [self.receivedData length];
    self.bytesDownloaded.text = [NSString stringWithFormat:@"%u", bytesReceived];
    NSTimeInterval et = -[self.startTime timeIntervalSinceNow];
    self.elapsedTime.text = [NSString stringWithFormat:@"%f", et];
    
    NSString *bwString;
    if (et > 0.0) {
        double bandwidth = bytesReceived/et;
        bandwidth = bandwidth * 8.0; // convert to bits/sec
        if (bandwidth < 1000.0) {
            bwString = [NSString stringWithFormat:@"%f Bits/sec", bandwidth];
        }
        else if (bandwidth < 1000000.0) {
            bwString = [NSString stringWithFormat:@"%6.1f Kb/s", bandwidth/1000.0];
        }
        else {
            bwString = [NSString stringWithFormat:@"%5.2f Mb/s", bandwidth/1000000.0];
        }
    } else {
        bwString = @"et Error";
    }
    self.downloadRate.text = bwString;
    
    [self.activity2 stopAnimating];
}

#pragma mark UIWebView delegate

// Methods to start/stop activity indicator
- (void)webViewDidStartLoad:(UIWebView *)wv
{
    [self.activity1 startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv
{
    [self.activity1 stopAnimating];
    NSURL *currentURL = [self.myWebView.request URL];
    self.URLText.text = [currentURL absoluteString];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.activity1 stopAnimating];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}


@end
