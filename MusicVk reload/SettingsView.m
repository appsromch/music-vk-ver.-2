//
//  SettingsView.m
//  MusicVk reload
//
//  Created by David Dreval on 05.09.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "SettingsView.h"

@interface SettingsView ()

@end

#pragma mark -
#pragma mark Implementation
@implementation SettingsView
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *)managedObjectC {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = @"";
		_revealBlock = [revealBlock copy];
        managedObjectContext = managedObjectC;
        NSLog(@"VkAudioManagedObject = %@", managedObjectContext);
        UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonBack setFrame:CGRectMake(40, 10, 30, 19)];
        [buttonBack setImage:[UIImage imageNamed:@"menu2.png"] forState:UIControlStateNormal];
        [buttonBack addTarget:self action:@selector(revealSidebar) forControlEvents:UIControlEventTouchUpInside];
        [buttonBack setImage:[UIImage imageNamed:@"menu2pressed.png"] forState:UIControlStateHighlighted];
        [buttonBack setShowsTouchWhenHighlighted:NO];
        UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                       initWithCustomView:buttonBack];
        [self.navigationItem setLeftBarButtonItem: backButton];
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setFrame:CGRectMake(10, 2, 200, 40)];
        [rightButton setBackgroundColor:[UIColor clearColor]];
        [rightButton setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [rightButton setTitle:title forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor colorWithWhite:0.1 alpha:1] forState:UIControlStateHighlighted];
        [rightButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
        [rightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [rightButton setEnabled:NO];
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [self.navigationItem setRightBarButtonItem:rightBarButton];
	}
	return self;
}

- (void) saveContext {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
