//
//  vkLogin.h
//  knowhat
//
//  Created by David Dreval on 12.02.12.
//  Copyright (c) 2012 D3 Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface vkLogin : UIViewController <UIWebViewDelegate> {
    
    id delegate;
    UIWebView *vkWebView;
    NSString *appID;
    UIActivityIndicatorView *indicator;
    
}
@property (nonatomic, retain) id delegate;
@property (nonatomic, retain) UIWebView *vkWebView;
@property (nonatomic, retain) NSString *appID;

- (NSString*)stringBetweenString:(NSString*)start 
                       andString:(NSString*)end 
                     innerString:(NSString*)str;


@end
