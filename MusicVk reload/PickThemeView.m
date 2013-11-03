//
//  PickThemeView.m
//  MusicVk reload
//
//  Created by David Dreval on 02.08.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "PickThemeView.h"

@interface PickThemeView ()

@end

@implementation PickThemeView
@synthesize pageController, save, cancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        CGRect screen = [[UIScreen mainScreen] bounds];
        NSArray *arr = [NSArray arrayWithObjects:@"playerbg1.jpg", @"playerbg2.jpg", @"playerbg3.jpg", @"playerbg4.jpg", @"playerbg5.jpg", nil];
        array = [[NSMutableArray alloc] init];
        index = 0;
        for (int i=0; i < 5; i++) {
            UIViewController *controllr = [[UIViewController alloc] init];
            UIView *view = [[UIView alloc] init];
            [view setFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
            NSLog(@"%f", view.frame.size.height);
            [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:[arr objectAtIndex:i]]]];
            [controllr setView:view];
            [array addObject:controllr];
        }
        self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        
        self.pageController.dataSource = self;
        [[self.pageController view] setFrame:CGRectMake(0, 0, screen.size.width, screen.size.height)];
        
        NSArray *viewControllers = [NSArray arrayWithObject:[array objectAtIndex:0]];
        [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
        
        [self addChildViewController:self.pageController];
        [self.view insertSubview:self.pageController.view atIndex:0];
        [self.pageController didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    int curInd = [array indexOfObject:viewController];
    NSLog(@"index = %d", curInd);
    index = curInd;
    if (curInd == 0) {
        return nil;
    }
    curInd--;
    UIViewController *controller = [array objectAtIndex:curInd];
    
    return controller;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    int curInd = [array indexOfObject:viewController];
    NSLog(@"index = %d", curInd);
    index = curInd;
    if (curInd == 4) {
        return nil;
    }
    curInd++;
    
    UIViewController *controller = [array objectAtIndex:curInd];
    
    return controller;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 5;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}

- (IBAction)saveFunc:(id)sender {
    NSArray *arr = [NSArray arrayWithObjects:@"playerbg1.jpg", @"playerbg2.jpg", @"playerbg3.jpg", @"playerbg4.jpg", @"playerbg5.jpg", nil];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setValue:[arr objectAtIndex:index] forKey:@"bgPic"];
    [ud synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newBg" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newPlayerBg" object:nil];
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)cancelFunc:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


@end
