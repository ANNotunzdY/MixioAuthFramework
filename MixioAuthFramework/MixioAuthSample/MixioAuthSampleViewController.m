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
#import "MixioAuthConnection.h"
#import "JSON.h"

NSString* const kMixioAuthConsumerKey = @"66ba941cd0a4a3804a15";
NSString* const kMixioAuthConsumerSecret = @"72dde8aa3bfed064619b73344e150f32f6789e2f";
NSString* const kMixioAuthURLString = @"https://mixi.jp/connect_authorize.pl?client_id=66ba941cd0a4a3804a15&response_type=code&scope=r_profile%20r_message%20w_message%20r_voice%20w_voice&display=touch";
NSString* const kMixioAuthRedirectURLString = @"https://mixi.jp/connect_authorize_success.html";

@implementation MixioAuthSampleViewController

@synthesize token, refreshHandler;

- (void)dealloc
{
	[refreshHandler release];
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
	
	self.refreshHandler = ^(MixioAuthToken * oldToken, void(^refreshCompletionHandler)(MixioAuthToken *newToken, NSError* error))
	{
		[self launchoAuthViewWithCompletionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
			refreshCompletionHandler(oAuthToken, error);
		}];
	};
		
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
	[self launchoAuthViewWithCompletionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
		if (oAuthToken) {
			self.token = oAuthToken;
			[oAuthToken saveToStandardUserDefaults];
		}
	}];
}

- (void)launchoAuthViewWithCompletionHandler:(void(^)(MixioAuthToken *oAuthToken, NSError *error))completionHandler {
	MixioAuthViewController* oAuthViewController = [[MixioAuthViewController alloc] init];
	[self presentModalViewController:oAuthViewController animated:YES];
	[oAuthViewController oAuthWithURL:[NSURL URLWithString:kMixioAuthURLString] redirectURL:[NSURL URLWithString:kMixioAuthRedirectURLString] completionHandler:^(NSString *authorizationCode, NSError *error) {
		NSLog(@"Authorization Code: %@", authorizationCode);
		if (authorizationCode) {
			MixioAuthTokenManager* oAuthTokenManager = [[MixioAuthTokenManager alloc] init];
			[oAuthTokenManager getAccessTokenWithAuthorizationCode:authorizationCode consumerKey:kMixioAuthConsumerKey consumerSecret:kMixioAuthConsumerSecret redirectURL:[NSURL URLWithString:kMixioAuthRedirectURLString] completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
				NSLog(@"%@", [oAuthToken description]);
				if (oAuthToken) {
					completionHandler(oAuthToken, nil);
				} else {
					completionHandler(nil, error);
				}
				[oAuthTokenManager release];
			}];
		} else {
			completionHandler(nil, error);
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
	[oAuthTokenManager refreshToken:self.token completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
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

- (IBAction)getMyProfile:sender {
	MixioAuthConnection* connection = [[MixioAuthConnection alloc] init];
	[connection connectToURL:[NSURL URLWithString:@"http://api.mixi-platform.com/2/people/@me/@self"] token:self.token refreshHandler:self.refreshHandler completionHandler:^(NSString *receivedString, NSError *error) 
	{
		NSDictionary* dictionary = [receivedString JSONValue];
		if (dictionary) {
			NSLog(@"%@", [dictionary description]);
		} else {
			NSLog(@"Profile Get Failed.");
		}
	}];
}

@end
