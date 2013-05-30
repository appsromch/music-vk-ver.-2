//
//  customNSURLConnection.h
//  MusicVk reload
//
//  Created by David Dreval on 12.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomURLConnection : NSURLConnection {
    NSString *tag;
}

@property (nonatomic, retain) NSString *tag;

- (id)initWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately tag:(NSString*)tag;

@end
