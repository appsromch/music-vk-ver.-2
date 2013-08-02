//
//  RootViewController.m
//  RESideMenuExample
//
//  Created by Roman Efimov on 6/26/13.
//  Copyright (c) 2013 Roman Efimov. All rights reserved.
//

#import "RootViewController.h"
#import "GHRootViewController.h"
#import "VkAudioViewController.h"
#import "AppDelegate.h"
#import "ItunesViewController.h"
#import "NavController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	//self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(showMenu)];
    UIButton *buttonBack = [UIButton buttonWithType:UIButtonTypeCustom];
    [buttonBack setBackgroundColor:[UIColor clearColor]];
    [buttonBack setFrame:CGRectMake(40, 10, 30, 19)];
    [buttonBack setImage:[UIImage imageNamed:@"menu2.png"] forState:UIControlStateNormal];
    [buttonBack addTarget:self action:@selector(showMenu) forControlEvents:UIControlEventTouchUpInside];
    [buttonBack setImage:[UIImage imageNamed:@"menu2pressed.png"] forState:UIControlStateHighlighted];
    [buttonBack setShowsTouchWhenHighlighted:NO];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]
                                   initWithCustomView:buttonBack];
    [self.navigationItem setLeftBarButtonItem: backButton];
}

#pragma mark -
#pragma mark Button actions

- (void)showMenu
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray *controllers = appDelegate.controllers;
    if (!_sideMenu) {
        RESideMenuItem *homeItem = [[RESideMenuItem alloc] initWithTitle:@" Сохраненные" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            [menu setRootViewController:controllers[0][0]];
        }];
        RESideMenuItem *exploreItem = [[RESideMenuItem alloc] initWithTitle:@" Плейлисты" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            [menu setRootViewController:controllers[0][1]];
        }];
        RESideMenuItem *activityItem = [[RESideMenuItem alloc] initWithTitle:@" Настройки" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            NSLog(@"Item %@", item);
            [menu setRootViewController:controllers[0][2]];
        }];
        RESideMenuItem *profileItem = [[RESideMenuItem alloc] initWithTitle:@" Аудиозаписи" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            NSLog(@"Item %@", item);
            [menu setRootViewController:controllers[1][0]];
        }];
        RESideMenuItem *aroundMeItem = [[RESideMenuItem alloc] initWithTitle:@" Itunes" action:^(RESideMenu *menu, RESideMenuItem *item) {
            [menu hide];
            NSLog(@"Item %@", item);
            [menu setRootViewController:controllers[1][1]];
        }];
        
        RESideMenuItem *helpPlus1 = [[RESideMenuItem alloc] initWithTitle:@" Рекомендации" action:^(RESideMenu *menu, RESideMenuItem *item) {
            NSLog(@"Item %@", item);
            [menu hide];
            [menu setRootViewController:controllers[1][2]];
        }];
        
        RESideMenuItem *helpPlus2 = [[RESideMenuItem alloc] initWithTitle:@" Поиск" action:^(RESideMenu *menu, RESideMenuItem *item) {
            NSLog(@"Item %@", item);
            [menu hide];
            [menu setRootViewController:controllers[1][3]];
        }];
        
        RESideMenuItem *logOutItem = [[RESideMenuItem alloc] initWithTitle:@" Log out" action:^(RESideMenu *menu, RESideMenuItem *item) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:@"Are you sure you want to log out?" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Log Out", nil];
            [alertView show];
        }];
        
        // в апдейте ОС 7, когда будет работать импорт из itunes, поставить после homeItem aroundMeItem
        
        _sideMenu = [[RESideMenu alloc] initWithItems:@[homeItem,  exploreItem, activityItem, profileItem, helpPlus1, helpPlus2, logOutItem]];
        _sideMenu.verticalOffset = IS_WIDESCREEN ? 110 : 76;
        _sideMenu.hideStatusBarArea = [AppDelegate OSVersion] < 7;
    }
    
    [_sideMenu show];
}

@end
