//
//  MixioAuthSampleViewController.m
//  MixioAuthSample
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthSampleViewController.h"
#import "MixioAuthViewController.h"
#import "MixioAuthTokenManager.h"

NSString* const kMixioAuthConsumerKey = @"66ba941cd0a4a3804a15";
NSString* const kMixioAuthConsumerSecret = @"9ae2112e7b14cffe1acf29b0a10c74acd7245a2b";
NSString* const kMixioAuthURLString = @"https://mixi.jp/connect_authorize.pl?client_id=66ba941cd0a4a3804a15&response_type=code&scope=r_profile&display=touch";
NSString* const kMixioAuthRedirectURLString = @"https://mixi.jp/connect_authorize_success.html";

@implementation MixioAuthSampleViewController

@synthesize token;

- (void)dealloc
{
	[token release];
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
		[self refresh:nil];
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

- (IBAction)launchoAuthView:sender {
	MixioAuthViewController* oAuthViewController = [[MixioAuthViewController alloc] init];
	[self presentModalViewController:oAuthViewController animated:YES];
	[oAuthViewController oAuthWithURL:[NSURL URLWithString:kMixioAuthURLString] redirectURL:[NSURL URLWithString:kMixioAuthRedirectURLString] completionHandler:^(NSString *authorizationCode, NSError *error) {
		NSLog(@"Authorization Code: %@", authorizationCode);
		if (authorizationCode) {
			MixioAuthTokenManager* oAuthTokenManager = [[MixioAuthTokenManager alloc] init];
			[oAuthTokenManager getAccessTokenWithAuthorizationCode:authorizationCode consumerKey:kMixioAuthConsumerKey consumerSecret:kMixioAuthConsumerSecret redirectURL:[NSURL URLWithString:kMixioAuthRedirectURLString] completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
				NSLog(@"%@", [oAuthToken description]);
				if (oAuthToken) {
					self.token = oAuthToken;
					[oAuthToken saveToStandardUserDefaults];
				}
				[oAuthTokenManager release];
			}];
		}
		[self dismissModalViewControllerAnimated:YES];
		[oAuthViewController release];
	}];
}

- (IBAction)refresh:sender {
	self.token = [MixioAuthToken loadFromStandardUserDefaults];
	if (!self.token) {
		[self launchoAuthView:nil];
		return;
	}
	
	MixioAuthTokenManager* oAuthTokenManager = [[MixioAuthTokenManager alloc] init];
	[oAuthTokenManager getAccessTokenWithRefreshToken:self.token.refreshToken consumerKey:kMixioAuthConsumerKey consumerSecret:kMixioAuthConsumerSecret completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
		NSLog(@"%@", [oAuthToken description]);
		if (oAuthToken) {
			self.token = oAuthToken;
			[oAuthToken saveToStandardUserDefaults];
		} else {
			[MixioAuthToken removeTokenFromUserDefaults];
			[self launchoAuthView:nil];
		}
		[oAuthTokenManager release];
	}];
}

@end
