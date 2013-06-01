//
//  NavController.m
//  Quoter
//
//  Created by David Dreval on 13.01.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "NavController.h"

@interface NavController ()

@end

@implementation NavController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.navigationBar setAlpha:1];
      //  [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navBg2.png"] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"navnew.png"] forBarMetrics:UIBarMetricsDefault];
       
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSString *bgname = [ud objectForKey:@"bgPic"];
        if (bgname == nil) {
            bgname = @"player1.jpg";
            [ud setValue:bgname forKey:@"bgPic"];
            [ud synchronize];
        }
        [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:bgname]]];
        
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
