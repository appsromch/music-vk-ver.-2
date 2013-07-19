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

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface NavController ()

@end

@implementation NavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationBar setAlpha:1];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *bgname = [ud objectForKey:@"bgPic"];
        NSLog(@"bg name = %@", bgname);
        if (bgname == nil) {
            bgname = @"playerbg1.jpg";
            [ud setValue:bgname forKey:@"bgPic"];
            [ud synchronize];
        }
        UIImage *img = [UIImage imageNamed:bgname];
        
        
      //  UIImage *blur = [img stackBlur:15];
        
        
       // img = [img imageWithBrightness:0.99f];
      
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            NSLog(@"less that 7");
            [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navNew.png"] forBarMetrics:UIBarMetricsDefault];
            [ud setObject:@"0" forKey:@"padding"];
            [ud synchronize];
        }
        else {
            NSLog(@"more than 7");
            [ud setObject:@"20" forKey:@"padding"];
            [ud synchronize];
            [self.navigationBar setBackgroundImage:img forBarMetrics:UIBarMetricsDefault];
        }
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
