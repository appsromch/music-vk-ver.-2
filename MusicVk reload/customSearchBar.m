//
//  customSearchBar.m
//  MusicVk reload
//
//  Created by David Dreval on 05.06.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "customSearchBar.h"
#import <QuartzCore/QuartzCore.h>

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

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
    UIView *subbg;
    NSUInteger numViews = 0;
    UIView *bg;
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        bg = [self.subviews objectAtIndex:0];
        numViews = [self.subviews count];
        NSLog(@"%@", self.subviews);
        if ([bg isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) {
            [bg setAlpha:0];
        }
        for(int i = 0; i < numViews; i++) {
            if([[self.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
                NSLog(@"%d", i);
                searchField = [self.subviews objectAtIndex:i];
            }
        }
    }
    else {
        bg = [self.subviews objectAtIndex:0];
        numViews = [bg.subviews count];
        subbg = [bg.subviews objectAtIndex:0];
        if ([subbg isKindOfClass:NSClassFromString(@"UISearchBarBackground") ] ) {
            [subbg setAlpha:0];
        }
        for(int i = 0; i < numViews; i++) {
            if([[bg.subviews objectAtIndex:i] isKindOfClass:[UITextField class]]) { //conform?
                searchField = [bg.subviews objectAtIndex:i];
            }
        }
    }
           // ПРОВЕРКА НА НОМЕР ОС 6 или 7 И ИСПРАВЛЕНИЕ
    
    if(!(searchField == nil)) {
        UIImageView *srcimg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchNew2.png"]];
        [srcimg setAlpha:0.13];
        [srcimg setFrame:CGRectMake(7, 7, 25, 25)];
        searchField.leftView = srcimg;
        searchField.textColor = [UIColor whiteColor];
        [searchField setEnablesReturnKeyAutomatically:NO];
        [searchField setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
        [searchField setBackground:[UIImage imageNamed:@"searchbg2.png"] ];
        [searchField setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.2]];
        [searchField.layer setCornerRadius:3.0f];
        [searchField setBorderStyle:UITextBorderStyleNone];
        NSLog(@"%@", searchField.subviews);
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
