//
//  MixioAuthSampleViewController.m
//  MixioAuthSample
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthSampleViewController.h"
#import "MixioAuthViewController.h"

NSString* const kMixioAuthConsumerKey = @"66ba941cd0a4a3804a15";
NSString* const kMixioAuthURLString = @"https://mixi.jp/connect_authorize.pl?client_id=66ba941cd0a4a3804a15&response_type=code&scope=r_profile&display=touch";
NSString* const kMixioAuthRedirectURLString = @"https://mixi.jp/connect_authorize_success.html";

@implementation MixioAuthSampleViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	dispatch_async(dispatch_get_main_queue(), ^{
		MixioAuthViewController* oAuthViewController = [[MixioAuthViewController alloc] init];
		[self presentModalViewController:oAuthViewController animated:YES];
		[oAuthViewController oAuthWithURL:[NSURL URLWithString:kMixioAuthURLString] redirectURL:[NSURL URLWithString:kMixioAuthRedirectURLString] completionHandler:^(NSString *authorizationCode, NSError *error) {
			NSLog(@"Authorization Code: %@", authorizationCode);
			[self dismissModalViewControllerAnimated:YES];
			[oAuthViewController release];
		}];
	});
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
