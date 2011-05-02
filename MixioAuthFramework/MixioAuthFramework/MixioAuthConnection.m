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
@property (copy, nonatomic) void(^refreshHandler)(MixioAuthToken *oAuthToken, void(^refreshCompletionHandler)(MixioAuthToken *oAuthToken, NSError* error));
@property (retain, nonatomic) MixioAuthToken* currentToken;
@property (retain, nonatomic) NSURL* currentURL;
@property (retain, nonatomic) NSMutableData* receivedData;
@end

@implementation MixioAuthConnection

@synthesize completionHandler, refreshHandler, receivedData, currentToken, currentURL;

- (void)dealloc {
	[completionHandler release];
	[refreshHandler release];
	[receivedData release];
	[currentToken release];
	[currentURL release];
	[super dealloc];
}

- (void)connectToURL:(NSURL *)aURL token:(MixioAuthToken *)token refreshHandler:(void(^)(MixioAuthToken *oAuthToken, void(^refreshCompletionHandler)(MixioAuthToken *oAuthToken, NSError* error)))aRefreshHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler {
	
	if (!token) {
		if (aCompletionHandler) {
			aCompletionHandler(nil, nil);
			return;
		}
	}
	
	if ([[token expireDate] compare:[NSDate date]] == NSOrderedAscending) {
		MixioAuthTokenManager* tokenManager = [[MixioAuthTokenManager alloc] init];
		[tokenManager refreshToken:token completionHandler:^(MixioAuthToken *oAuthToken, NSError *error) {
			if (oAuthToken) {
				self.currentToken = oAuthToken;
				[self connectToURL:aURL accessToken:oAuthToken.accessToken refreshHandler:aRefreshHandler completionHandler:aCompletionHandler];
			} else {
				self.currentToken = token;
				[self connectToURL:aURL accessToken:token.accessToken refreshHandler:aRefreshHandler completionHandler:aCompletionHandler];
			}
			[tokenManager release];
		}];
		return;
	}
	
	self.currentToken = token;
	[self connectToURL:aURL accessToken:token.accessToken refreshHandler:aRefreshHandler completionHandler:aCompletionHandler];
}

- (void)connectToURL:(NSURL *)aURL accessToken:(NSString *)accessToken refreshHandler:(void(^)(MixioAuthToken *oAuthToken, void(^refreshCompletionHandler)(MixioAuthToken *oAuthToken, NSError* error)))aRefreshHandler completionHandler:(void(^)(NSString* receivedString, NSError *error))aCompletionHandler {
	
	if (!accessToken) {
		if (self.completionHandler) {
			aCompletionHandler(nil, nil);
			return;
		}
	}
	
	self.completionHandler = aCompletionHandler;
	self.refreshHandler = aRefreshHandler;
	self.currentURL = aURL;
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
	NSLog(@"Error: %@ (Code:%d)", [error localizedDescription], [error code]);
	if (self.completionHandler) {
		completionHandler(nil, error);
	}
	self.completionHandler = nil;
	self.refreshHandler = nil;
	self.currentToken = nil;
	self.receivedData = nil;
	[connection release];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Response Code: %d", [(NSHTTPURLResponse *)response statusCode]);
	if ([(NSHTTPURLResponse *)response statusCode] == 401) {
		if (refreshHandler) {
			code401Received = YES;
			refreshHandler(currentToken, ^(MixioAuthToken *oAuthToken, NSError* error){
				if (oAuthToken) {
					self.currentToken = oAuthToken;
					[self connectToURL:currentURL accessToken:oAuthToken.accessToken refreshHandler:nil completionHandler:completionHandler];
				} else {
					if (self.completionHandler) {
						completionHandler(nil, error);
					}
					self.completionHandler = nil;
					self.refreshHandler = nil;
					self.currentToken = nil;
					self.receivedData = nil;
					[connection release];
				}
			});
			return;
		}
	}
	
	self.refreshHandler = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Finish Loading.");
	if (code401Received) {
		NSLog(@"401 Received. This response neglected.");
		code401Received = NO;
		return;
	}
	NSString* receiveString = [[[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding] autorelease];
	if (self.completionHandler) {
		completionHandler(receiveString, nil);
		self.completionHandler = nil;
	} else {
		NSLog(@"completion handler is not found.");
	}
	
	[connection release];
	self.receivedData = nil;
	self.refreshHandler = nil;
	self.currentToken = nil;
}


@end
