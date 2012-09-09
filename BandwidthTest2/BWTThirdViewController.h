//
//  BWTThirdViewController.h
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BWTThirdViewController : UIViewController

// Data properties

@property (nonatomic, strong) NSDate *startTime1;
@property (nonatomic, strong) NSDate *startTime2;
@property (nonatomic, strong) NSDate *startTime3;
@property (nonatomic, strong) NSMutableArray *downloads;

// Outlets
// Would have been better to use Outlet Collections (maybe version 2): See http://bit.ly/QceExB
// URL Text Fields
@property (weak, nonatomic) IBOutlet UITextField *URL1Text;
@property (weak, nonatomic) IBOutlet UITextField *URL2Text;
@property (weak, nonatomic) IBOutlet UITextField *URL3Text;

// Activity indicators
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity1;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity2;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity3;

// Text field actions
- (IBAction)URL1TextAction:(id)sender;
- (IBAction)URL2TextAction:(id)sender;
- (IBAction)URL3TextAction:(id)sender;

// Bandwidth display Text Fields
@property (weak, nonatomic) IBOutlet UITextField *bandwidth1Text;
@property (weak, nonatomic) IBOutlet UITextField *bandwidth2Text;
@property (weak, nonatomic) IBOutlet UITextField *bandwidth3Text;

// Switches
@property (weak, nonatomic) IBOutlet UISwitch *URL1Button;
@property (weak, nonatomic) IBOutlet UISwitch *URL2Button;
@property (weak, nonatomic) IBOutlet UISwitch *URL3Button;

// Button Actions
- (IBAction)startBandwidthTestButton:(id)sender;
- (IBAction)resetDefaultsButton:(id)sender;

@end
