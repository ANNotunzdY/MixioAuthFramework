//
//  MixioAuthViewController.h
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MixioAuthViewController : UIViewController <UIWebViewDelegate> {
	IBOutlet UIWebView* webView;
	IBOutlet UIView* loadingView;
	IBOutlet UIActivityIndicatorView* indicator;
}

- (void)oAuthWithURL:(NSURL *)aURL redirectURL:(NSURL *)aRedirectURL completionHandler:(void(^)(NSString *accessToken, NSError *error))aCompletionHandler;

- (IBAction)close:sender;
- (void)showIndicator;
- (void)hideIndicator;

@end
