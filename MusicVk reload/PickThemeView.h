//
//  PickThemeView.h
//  MusicVk reload
//
//  Created by David Dreval on 02.08.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickThemeView : UIViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate> {
    NSUInteger index;
    NSMutableArray *array;
}

@property (strong, nonatomic) UIPageViewController *pageController;
@property (nonatomic, retain) IBOutlet UIButton *cancel;
@property (nonatomic, retain) IBOutlet UIButton *save;

- (IBAction)cancelFunc:(id)sender;
- (IBAction)saveFunc:(id)sender;


@end
