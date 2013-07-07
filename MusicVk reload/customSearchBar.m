//
//  customSearchBar.m
//  MusicVk reload
//
//  Created by David Dreval on 05.06.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "customSearchBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation customSearchBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    UITextField *searchField;
    NSUInteger numViews = [self.subviews count];
    NSLog(@"%@", self.subviews);
    UIView *bg = [self.subviews objectAtIndex:0];
    if ([bg isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] )
        bg.alpha = 0.0;
    for(int i = 0; i < numViews; i++) {
        if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
            searchField = [self.subviews objectAtIndex:i];
        }
    }
    if(!(searchField == nil)) {
        UIImageView *srcimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchNew2.png"]];
        [srcimg setAlpha:0.13];
        [srcimg setFrame:CGRectMake(7, 7, 25, 25)];
        searchField.leftView = srcimg;
        searchField.textColor = [UIColor whiteColor];
        [searchField setEnablesReturnKeyAutomatically:NO];
        [searchField setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
       // [searchField setBackground:[UIImage imageNamed:@"searchbg.png"] ];
        [searchField setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.3]];
        [searchField.layer setCornerRadius:3.0f];
        [searchField setBorderStyle:UITextBorderStyleNone];
    }
    
    [super layoutSubviews];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
