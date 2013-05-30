//
//  customNSURLConnection.m
//  MusicVk reload
//
//  Created by David Dreval on 12.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "customNSURLConnection.h"

/*-------------------------------------------------------------
 * IMPLEMENTATION
 *------------------------------------------------------------*/

@implementation CustomURLConnection

@synthesize tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag2 {
    self = [super initWithRequest:request delegate:delegate startImmediately:startImmediately];
    
    if (self) {
        self.tag = tag2;
    }
    return self;
}

@end
