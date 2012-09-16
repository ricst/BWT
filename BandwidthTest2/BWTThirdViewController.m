//
//  BWTThirdViewController.m
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import "BWTThirdViewController.h"
#import "MyDownloader.h"
#import "URLDefaults.h"

// 0 => enable debug logging. 1=> Disable debug logging
#define MyLog if(0); else NSLog

#define DOWNLOAD_TIMEOUT 15.0f

#define SEGMENT_INDEX_BITS 0

@interface BWTThirdViewController ()

@end

@implementation BWTThirdViewController

@synthesize startTime = _startTime;
@synthesize URLText = _URLText;
@synthesize activity = _activity;
@synthesize bandwidthText = _bandwidthText;
@synthesize URLButtons = _URLButtons;

@synthesize startTime1 = _startTime1;
@synthesize startTime2 = _startTime2;
@synthesize startTime3 = _startTime3;
@synthesize downloads = _downloads;

@synthesize bandwidth1Text;
@synthesize bandwidth2Text;
@synthesize bandwidth3Text;
@synthesize URL1Text;
@synthesize URL2Text;
@synthesize URL3Text;
@synthesize activity1;
@synthesize activity2;
@synthesize activity3;
@synthesize URL1Button;
@synthesize URL2Button;
@synthesize URL3Button;
@synthesize bitsBytesControl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Multi", @"Multi");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set initial URLs.
    self.URL1Text.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"URL1"];
    self.URL2Text.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"URL2"];
    self.URL3Text.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"URL3"];
    
    // initialize some arrays
    
    self.startTime = [NSMutableArray array];
    // Pad to initially create dummy objects, to be replaced during multi BW tests
    for (int i = 0; i < MAX_BW_OBJECTS; i++) {
        [self.startTime addObject:[NSNull null]];
    }
    
    self.URLText = [NSArray arrayWithObjects:self.URL1Text, self.URL2Text, self.URL3Text, nil];
    self.activity = [NSArray arrayWithObjects:self.activity1, self.activity2, self.activity3, nil];
    self.bandwidthText = [NSArray arrayWithObjects:self.bandwidth1Text, self.bandwidth2Text, self.bandwidth3Text, nil];
    self.URLButtons = [NSArray arrayWithObjects:self.URL1Button, self.URL2Button, self.URL3Button, nil];
}

- (void)viewDidUnload
{
    [self setURL1Text:nil];
    [self setURL2Text:nil];
    [self setURL3Text:nil];
    [self setURL1Button:nil];
    [self setURL2Button:nil];
    [self setURL3Button:nil];
    [self setBandwidth1Text:nil];
    [self setBandwidth2Text:nil];
    [self setBandwidth3Text:nil];
    [self setActivity1:nil];
    [self setActivity2:nil];
    [self setActivity3:nil];
    [self setBitsBytesControl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Switch to connectionWithRequest:delegate method
// Properties: conn1, conn2, conn3 to track in delegate.  
// Whenever the Start Download button is pushed, send a cancel message to all connections.
// conn1,2,3 to be nilified at finish.

// Start Downloads
// For each URL with a switch in the ON position, do the download and report bandwidth
- (IBAction)startBandwidthTestButton:(id)sender {

    if (!self.downloads) {
        self.downloads = [NSMutableArray array];
    }
    
    // Start new download(s), but old one(s) may still be in progress.
    // If any prior connection(s) still exist(s), cancel.
    if ([self.downloads count] > 0) {
        MyDownloader *myd;
        for (myd in self.downloads) {
            [myd.connection cancel];
            // Cancel all existing "connectionFinished" Notifications.  We will reestablsih these
            [[NSNotificationCenter defaultCenter] removeObserver:self name:CONNECTION_FINISHED object:myd];
        }
    }
            
    // For each URL with the switch set to ON, do the download and report the bandwidth.
    
    NSUInteger iurl = 0;
    // iurl is the actual URL Button index; starts at 0.
    for (UISwitch *uis in self.URLButtons) {
        if (uis.isOn) {
            //MyLog(@"Switch %i is ON", iurl + 1);
            //NSString *URLString = [URLs objectAtIndex:iurl];
            UITextField *tf = [self.URLText objectAtIndex:iurl];
            NSString *URLString = tf.text;
            URLString = [self formatStringWithHttp:URLString];  // prepend http:// if user omitted
            MyLog(@"URL %i = %@", iurl + 1, URLString);
            
            NSURL *url = [NSURL URLWithString:URLString];
            NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:DOWNLOAD_TIMEOUT];
            MyDownloader *dload = [[MyDownloader alloc] initWithRequest:req dloadID:iurl];
            [self.downloads addObject:dload];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finished:) name:CONNECTION_FINISHED object:dload];
            
            [[self.activity objectAtIndex:iurl] startAnimating];
            NSDate *startTime = [NSDate date];
            [self.startTime replaceObjectAtIndex:iurl withObject:startTime];
            [dload.connection start];
        }
        
        iurl++;  // increment URL counter, which starts at 0
    }  // end for loop
}  

// Notification received that download has finished.  Check for error.
// If OK, stop appropriate activity indicator and display bandwidth
// Finally, cancel notification and remove object from download array
- (void)finished: (NSNotification *)notify {
    MyDownloader *d = [notify object];
    NSData *data = nil;
    if ([notify userInfo]) {
        // Some kind of error happened
        MyLog(@"finished: Error detected: %@", [[[notify userInfo] objectForKey:@"error"] localizedDescription]);
    }
    else {
        //MyLog(@"finished: reached with data");
        data = d.receivedData;
        NSUInteger length = [data length];
        NSUInteger downloadID = d.downloadID;
        NSTimeInterval et;
        NSString *bwString;
        
        [[self.activity objectAtIndex:downloadID] stopAnimating];
        // Get count of bytes received and ET and then display BW
        et = -[[self.startTime objectAtIndex:downloadID] timeIntervalSinceNow];
        bwString = [self bandwidthString:length elapsedTime:et];
        UITextField *tf = [self.bandwidthText objectAtIndex:downloadID];
        tf.text = bwString;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CONNECTION_FINISHED object:d];
    [self.downloads removeObject:d];
}

- (NSString *)bandwidthString: (NSUInteger)bytes elapsedTime:(NSTimeInterval)et {
    
    NSString *bwString;
    BOOL bits;
    
    // See whether user has selected bits/sec or Bytes/sec output display
    if (self.bitsBytesControl.selectedSegmentIndex == SEGMENT_INDEX_BITS) {
        bits = YES;
    }
    else {
        bits = NO;
    }
    
    if (et > 0.0) {
        double bandwidth = bytes/et;
        if (bits) {
            bandwidth = bandwidth * 8.0; // BW is bits/sec
        }
        
        if (bandwidth < 1000.0) {
            if (bits)
                bwString = [NSString stringWithFormat:@"%f b/sec", bandwidth];
            else
                bwString = [NSString stringWithFormat:@"%f B/sec", bandwidth];
        }
        else if (bandwidth < 1000000.0) {
            if (bits)
                bwString = [NSString stringWithFormat:@"%6.1f Kb/sec", bandwidth/1000.0];
            else
                bwString = [NSString stringWithFormat:@"%6.1f KB/sec", bandwidth/1000.0];
        }
        else {
            if (bits)
                bwString = [NSString stringWithFormat:@"%5.2f Mb/sec", bandwidth/1000000.0];
            else
                bwString = [NSString stringWithFormat:@"%5.2f MB/sec", bandwidth/1000000.0];
        }
    }
    else {
        bwString = @"ET = 0 error";
    }

    return bwString;
}

// Reset URLs to original App defaults, clearing out any user set defaults
- (IBAction)resetDefaultsButton:(id)sender {
    
    self.URL1Text.text = URL1;
    [[NSUserDefaults standardUserDefaults] setObject:URL1 forKey:@"URL1"];
    self.URL2Text.text = URL2;
    [[NSUserDefaults standardUserDefaults] setObject:URL2 forKey:@"URL2"];
    self.URL3Text.text = URL3;
    [[NSUserDefaults standardUserDefaults] setObject:URL3 forKey:@"URL3"];
    
    MyLog(@"NSUserDefaults URLs now:");
    for (NSString *url in @[@"URL1", @"URL2", @"URL3"]) {
        MyLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:url]);
    }
}

// Actions when user finishes entering text
// Save new URL into NSUserDefaults
- (IBAction)URL1TextAction:(id)sender {
    
    NSString *urlString = self.URL1Text.text;
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"URL1"];
}

- (IBAction)URL2TextAction:(id)sender {
    
    NSString *urlString = self.URL2Text.text;
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"URL2"];
}

- (IBAction)URL3TextAction:(id)sender {
    
    NSString *urlString = self.URL3Text.text;
    [[NSUserDefaults standardUserDefaults] setObject:urlString forKey:@"URL3"];
    MyLog(@"URL3 text stored in NSUserDefaults as: %@", urlString);
}

// Prepend "http://" if string does not start with "http"
// This allows https to remain unaltered, but adds http:// if user left off
- (NSString *)formatStringWithHttp:(NSString *)urlText {
    
    if (![urlText hasPrefix:@"http"]) {
        urlText = [@"http://" stringByAppendingString:urlText];
    }
    return urlText;
}

@end
