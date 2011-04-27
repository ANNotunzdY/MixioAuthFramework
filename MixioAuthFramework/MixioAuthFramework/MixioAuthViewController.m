//
//  MixioAuthViewController.m
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthViewController.h"

@interface MixioAuthViewController ()
@property (copy, nonatomic) void (^completionHandler)(NSString *authorizationCode, NSError *error);
@property (retain, nonatomic) NSURL* redirectURL;
@end

@implementation MixioAuthViewController

@synthesize completionHandler, redirectURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
	browserView.delegate = nil;
	[completionHandler release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)close:sender {
	if (self.completionHandler) {
		completionHandler(nil, [NSError errorWithDomain:@"MixioAuthViewControllerErrorDomain" code:0 userInfo:nil]);
	}
	self.completionHandler = nil;
}

- (void)oAuthWithURL:(NSURL *)aURL redirectURL:(NSURL *)aRedirectURL completionHandler:(void(^)(NSString *accessToken, NSError *error))aCompletionHandler {
	
	if (self.completionHandler) {
		aCompletionHandler(nil, nil);
		return;
	}
	
	self.completionHandler = aCompletionHandler;
	self.redirectURL = aRedirectURL;
	
	[browserView loadRequest:[NSURLRequest requestWithURL:aURL]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self showIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self hideIndicator];
	
	if ([[webView.request.URL absoluteString] 
		 rangeOfString:[self.redirectURL absoluteString]].location == 0) {
		NSArray* components = [[webView.request.URL absoluteString] componentsSeparatedByString:@"code="];
		if ([components count] < 2) {
			if (self.completionHandler) {
				completionHandler(nil, [NSError errorWithDomain:@"MixioAuthViewControllerErrorDomain" code:1 userInfo:nil]);
			}
			self.completionHandler = nil;
			return;
		}
		if (self.completionHandler) {
			completionHandler([components objectAtIndex:1], nil);
		}
		self.completionHandler = nil;
	}
}
	 
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self hideIndicator];
	if (self.completionHandler) {
		completionHandler(nil, error);
	}
	self.completionHandler = nil;
}

- (void)showIndicator {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (![loadingView superview]) {
			[self.view addSubview:loadingView];
		}
		[indicator startAnimating];
	});
}

- (void)hideIndicator {
	dispatch_async(dispatch_get_main_queue(), ^{
		[indicator stopAnimating];
		if ([loadingView superview]) {
			[loadingView removeFromSuperview];
		}
	});
}

@end
