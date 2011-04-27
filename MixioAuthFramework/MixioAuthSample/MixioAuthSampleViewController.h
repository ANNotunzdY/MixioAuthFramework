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

- (IBAction)launchoAuthView:sender;
- (IBAction)refresh:sender;
- (IBAction)getMyProfile:sender;

@end
