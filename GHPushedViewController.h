//
//  GHPushedViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/29/11.
//

#import <Foundation/Foundation.h>

@interface GHPushedViewController : UIViewController {
    CGRect quoteFrame;
    NSString *bashString;
    NSString *timeString;
    NSString *numberString;
}

- (id)initWithTitle:(NSString *)title;

@end
