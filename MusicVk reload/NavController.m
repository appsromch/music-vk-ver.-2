//
//  NavController.m
//  Quoter
//
//  Created by David Dreval on 13.01.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "NavController.h"
#import "UIImage+StackBlur.h"
#import "UIImage+Brightness.h"

@interface NavController ()

@end

@implementation NavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationBar setAlpha:1];
        
      //  [self.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
       // [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navnew.png"] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
       // [self.navigationBar setBackgroundColor:[UIColor clearColor]];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *bgname = [ud objectForKey:@"bgPic"];
        if ([bgname isEqualToString:@""]) {
            bgname = @"player1.jpg";
            [ud setValue:bgname forKey:@"bgPic"];
            [ud synchronize];
        }
        UIImage *img = [UIImage imageNamed:bgname];
        
        
      //  UIImage *blur = [img stackBlur:15];
        
        
       // blur = [blur imageWithBrightness:-0.6f];
      
        
        // [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navNew.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:img]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setBg)
                                                     name:@"newBg"
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) setBg {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[ud objectForKey:@"bgPic"]]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
