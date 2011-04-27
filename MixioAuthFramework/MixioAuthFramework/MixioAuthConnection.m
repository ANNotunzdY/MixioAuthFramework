//
//  MixioAuthConnection.m
//  MixioAuthFramework
//
//  Created by あんのたん on 11/04/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MixioAuthConnection.h"
#import "MixioAuthTokenManager.h"

@interface MixioAuthConnection ()
@property (copy, nonatomic) void (^completionHandler)(NSString* receivedString, NSError *error);
@property (retain, nonatomic) NSMutableData* receivedData;
@end

@implementation MixioAuthConnection

@synthesize completionHandler, receivedData;

- (void)dealloc {
	[completionHandler release];
	[receivedData release];
	[super dealloc];
}

- (void)connectToURL:(NSURL *)aURL token:(MixioAuthToken *)token refreshingHandler:(void(^)(MixioAuthToken *oAuthToken))refreshingHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler {
	
	if ([[token expireDate] compare:[NSDate date]] == NSOrderedAscending) {
		MixioAuthTokenManager* tokenManager = [[MixioAuthTokenManager alloc] init];
		[tokenManager refreshToken:token completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
			if (refreshingHandler) {
				refreshingHandler(oAuthToken);
			}
			if (oAuthToken) {
				[self connectToURL:aURL accessToken:oAuthToken.accessToken completionHandler:aCompletionHandler];
			}
		}];
		return;
	}
	
	if (!token) {
		if (self.completionHandler) {
			aCompletionHandler(nil, nil);
			return;
		}
	}
	
	[self connectToURL:aURL accessToken:token.accessToken completionHandler:aCompletionHandler];
}

- (void)connectToURL:(NSURL *)aURL accessToken:(NSString *)accessToken completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler {
	
	if (self.completionHandler) {
		aCompletionHandler(nil, nil);
		return;
	}
	
	if (!accessToken) {
		if (self.completionHandler) {
			aCompletionHandler(nil, nil);
			return;
		}
	}
	
	self.completionHandler = aCompletionHandler;
	NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:aURL];
	[request setHTTPMethod:@"GET"];
	[request setValue:[NSString stringWithFormat:@"OAuth %@", accessToken] forHTTPHeaderField:@"Authorization"];
	
	NSURLConnection* connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (connection) {
		self.receivedData = [NSMutableData data];
		[connection start];
	} else {
		if (self.completionHandler) {
			completionHandler(nil, [NSError errorWithDomain:@"MixioAuthConnectionErrorDomain" code:1 userInfo:nil]);
		}
		self.completionHandler = nil;
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if (self.completionHandler) {
		completionHandler(nil, error);
	}
	self.completionHandler = nil;
	[connection release];
	self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString* receiveString = [[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease];
	if (self.completionHandler) {
		completionHandler(receiveString, nil);
		self.completionHandler = nil;
	}
	
	[connection release];
	self.receivedData = nil;
}


@end
