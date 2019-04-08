/*

File: MainViewController.m
Abstract: Controller class for the "main" view (visible at app start).

Version: 1.1

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple Inc.
("Apple") in consideration of your agreement to the following terms, and your
use, installation, modification or redistribution of this Apple software
constitutes acceptance of these terms.  If you do not agree with these terms,
please do not use, install, modify or redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and subject
to these terms, Apple grants you a personal, non-exclusive license, under
Apple's copyrights in this original Apple software (the "Apple Software"), to
use, reproduce, modify and redistribute the Apple Software, with or without
modifications, in source and/or binary forms; provided that if you redistribute
the Apple Software in its entirety and without modifications, you must retain
this notice and the following text and disclaimers in all such redistributions
of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may be used
to endorse or promote products derived from the Apple Software without specific
prior written permission from Apple.  Except as expressly stated in this notice,
no other rights or licenses, express or implied, are granted by Apple herein,
including but not limited to any patent rights that may be infringed by your
derivative works or by other works in which the Apple Software may be
incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES NO
WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE IMPLIED
WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION ALONE OR IN
COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, MODIFICATION AND/OR
DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND WHETHER UNDER THEORY OF
CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT LIABILITY OR OTHERWISE, EVEN IF
APPLE HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2008 Apple Inc. All Rights Reserved.

*/

#import "MainViewController.h"

@implementation MainViewController

@synthesize flipDelegate, updateTextView, startStopButton, spinner;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		isCurrentlyUpdating = NO;
		firstUpdate = YES;
	}
	return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[updateTextView release];
	[startStopButton release];
	[spinner release];
    
	[super dealloc];
}


// Appends some text to the main text view
// If this is the first update, it will replace the existing text
-(void)addTextToLog:(NSString *)text {
	if (firstUpdate) {
		updateTextView.text = text;
		firstUpdate = NO;
	} else {
		updateTextView.text = [NSString stringWithFormat:@"%@-----\n\n%@", updateTextView.text, text];
		[updateTextView scrollRangeToVisible:NSMakeRange([updateTextView.text length], 0)]; // scroll to the bottom on updates
	}
}

// Called when the view is loading for the first time only
// If you want to do something every time the view appears, use viewWillAppear or viewDidAppear
- (void)viewDidLoad {
	[startStopButton setTitle:NSLocalizedString(@"StartButton", @"Start")];
	[MyCLController sharedInstance].delegate = self;

    // Check to see if the user has disabled location services all together
    // In that case, we just print a message and disable the "Start" button
    if ( ! [MyCLController sharedInstance].locationManager.locationServicesEnabled ) {
        [self addTextToLog:NSLocalizedString(@"NoLocationServices", @"User disabled location services")];
        startStopButton.enabled = NO;
    }
}

#pragma mark ---- control callbacks ----

// Tells the root view, via a delegate, to flip over to the FlipSideView
- (IBAction)infoButtonPressed:(id)sender {
	[self.flipDelegate toggleView:self];
}

// Called when the "start/stop" button is pressed
-(IBAction)startStopButtonPressed:(id)sender {
	if (isCurrentlyUpdating) {
		[[MyCLController sharedInstance].locationManager stopUpdatingLocation];
		isCurrentlyUpdating = NO;
		[startStopButton setTitle:NSLocalizedString(@"StartButton", @"Start")];
		[spinner stopAnimating];
	} else {
		[[MyCLController sharedInstance].locationManager startUpdatingLocation];
		isCurrentlyUpdating = YES;
		[startStopButton setTitle:NSLocalizedString(@"StopButton", @"Stop")];
		[spinner startAnimating];
	}
}

#pragma mark ---- delegate methods for the MyCLController class ----

-(void)newLocationUpdate:(NSString *)text {
	[self addTextToLog:text];
}

-(void)newError:(NSString *)text {
	[self addTextToLog:text];
}

@end
