//
//  BWTThirdViewController.m
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import "BWTThirdViewController.h"
#import "MyDownloader.h"

// 0 => enable debug logging. 1=> Disable debug logging
#define MyLog if(0); else NSLog

#define TOTAL_URLS 3

// Some initial defaults that may later go into NSUserDefaults
#define DOWNLOAD_TIMEOUT 15.0f
#define URL1 @"http://www.youtube.com"
#define URL2 @"http://www.wikipedia.org"
#define URL3 @"http://www.ebay.com"

@interface BWTThirdViewController ()

@end

@implementation BWTThirdViewController

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
    
    // set initial URLs.  Maybe get from NSUserDefaults eventually
    self.URL1Text.text = URL1;
    self.URL2Text.text = URL2;
    self.URL3Text.text = URL3;
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Switch to connectionWithRequest:delegate method
// Properties: conn1, conn2, conn3 to track in delegate.  
// Whenever the Start Download button is pushed, send a cancel message to all connections.
// conn1,2,3 to be nilified at finish.

// Start Downloads
// For each URL with a switch in the ON position, do the download and report bandwidth
- (IBAction)startBandwidthTestButton:(id)sender {

    // Get text for URL 1, 2 and 3.  
    NSArray *URLs = [NSArray arrayWithObjects:self.URL1Text.text, self.URL2Text.text, self.URL3Text.text, nil];
    
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
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionFinished" object:myd];
        }
    }
            
    // For each URL with the switch set to ON, do the download and report the bandwidth.
    
    NSInteger iurl = 0;
    // iurl is the actual URL Button index; starts at 0.
    NSArray *URLSwitches = @[URL1Button, URL2Button, URL3Button];
    for (UISwitch *uis in URLSwitches) {
        if (uis.isOn) {
            //MyLog(@"Switch %i is ON", iurl + 1);
            NSString *URLString = [URLs objectAtIndex:iurl];
            MyLog(@"URL %i = %@", iurl + 1, URLString);
            
            NSURL *url = [NSURL URLWithString:URLString];
            NSURLRequest *req = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:DOWNLOAD_TIMEOUT];
            MyDownloader *dload = [[MyDownloader alloc] initWithRequest:req dloadID:iurl];
            [self.downloads addObject:dload];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finished:) name:CONNECTION_FINISHED object:dload];
            
            if (iurl == 0) {
                [self.activity1 startAnimating];
                self.startTime1 = [NSDate date];
                [dload.connection start];
            }
            else if (iurl == 1) {
                
            }
            else if (iurl == 2) {
                
            }
            else {
                MyLog(@"startBandwidthTest: should not reach here");
            }
        }
        
        iurl++;  // increment URL counter, which starts at 0
    }  // end for loop
}  

// Notification received that download has finished.  Check for error.
// If OK, stop appropriate activity indicator and display bandwidth
// Finally, cancel notification and remove object from download array
- (void)finished: (NSNotification *)note {
    MyDownloader *d = [note object];
    NSData *data = nil;
    if ([note userInfo]) {
        // Some kind of error happened
        MyLog(@"finished: Error detected: %@", [[[note userInfo] objectForKey:@"error"] localizedDescription]);
    }
    else {
        //MyLog(@"finished: reached with data");
        data = d.receivedData;
        NSUInteger length = [data length];
        NSUInteger downloadID = d.downloadID;
        NSTimeInterval et;
        NSString *bwString;
        
        //MyLog(@"DownloadID = %i", downloadID);
        
        // Separate case for each URL, activity indicator and timer.
        if (downloadID == 0) {
            [self.activity1 stopAnimating];
            et = -[self.startTime1 timeIntervalSinceNow];
            bwString = [self bandwidthString:length elapsedTime:et];
            self.bandwidth1Text.text = bwString;
        }
        else if (downloadID == 1) {
            
        }
        else if (downloadID == 2) {
            
        }
        else {
            MyLog(@"finished: Should never have this download ID: %u", downloadID);
        }
        // Get count of bytes received and ET and then display BW
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"connectionFinished" object:d];
    [self.downloads removeObject:d];
}

- (NSString *)bandwidthString: (NSUInteger)bytes elapsedTime:(NSTimeInterval)et {
    
    NSString *bwString;
    if (et > 0.0) {
        double bandwidth = bytes/et;
        if (bandwidth < 1000.0) {
            bwString = [NSString stringWithFormat:@"%f B/sec", bandwidth];
        }
        else if (bandwidth < 1000000.0) {
            bwString = [NSString stringWithFormat:@"%6.1f KB/s", bandwidth/1000.0];
        }
        else {
            bwString = [NSString stringWithFormat:@"%5.2f MB/s", bandwidth/1000000.0];
        }
    }
    else {
        bwString = @"ET 0 err";
    }

    return bwString;
}

- (IBAction)resetDefaultsButton:(id)sender {
}

// Actions when user finishes entering text
- (IBAction)URL1TextAction:(id)sender {
}

- (IBAction)URL2TextAction:(id)sender {
}

- (IBAction)URL3TextAction:(id)sender {
}
@end