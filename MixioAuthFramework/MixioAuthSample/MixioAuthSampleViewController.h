//
//  MixioAuthSampleViewController.h
//  MixioAuthSample
//
//  Created by あんのたん on 11/04/27.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MixioAuthToken.h"

@interface MixioAuthSampleViewController : UIViewController {
}
@property (retain, nonatomic) MixioAuthToken* token;
@property (copy, nonatomic) void(^refreshHandler)(MixioAuthToken* oldToken, void(^refreshCompletionHandler)(MixioAuthToken *newToken, NSError* error));

- (IBAction)launchoAuthView:sender;
- (void)launchoAuthViewWithCompletionHandler:(void(^)(MixioAuthToken *oAuthToken, NSError *error))completionHandler;
- (IBAction)refresh:sender;
- (IBAction)getMyProfile:sender;

@end
