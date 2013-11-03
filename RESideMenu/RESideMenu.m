//
//  RESideMenu.m
// RESideMenu
//
// Copyright (c) 2013 Roman Efimov (https://github.com/romaonthego)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "RESideMenu.h"
#import "AccelerationAnimation.h"
#import "Evaluate.h"
#import "CustomCell.h"
#import "UIImage+StackBlur.h"
#import "UIImage+Brightness.h"

#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

const int INTERSTITIAL_STEPS = 99;

@interface RESideMenu ()
{
    BOOL _appIsHidingStatusBar;
    BOOL _isInSubMenu;
}
@property (assign, readwrite, nonatomic) NSInteger initialX;
@property (assign, readwrite, nonatomic) CGSize originalSize;
@property (strong, readonly, nonatomic) REBackgroundView *backgroundView;
@property (strong, readonly, nonatomic) UIImageView *screenshotView;
@property (strong, readonly, nonatomic) UITableView *tableView;
@property (nonatomic, retain) UIButton *playerView;

// Array containing menu (which are array of items)
@property (strong, readwrite, nonatomic) NSMutableArray *menuStack;
@property (strong, readwrite, nonatomic) RESideMenuItem *backMenu;

@end

@implementation RESideMenu

- (id)init
{
    self = [super init];
    if (!self)
        return nil;
    NSLog(@"inited");
    self.verticalOffset = 100;
    self.horizontalOffset = 50;
    self.itemHeight = 50;
    self.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:21];
    self.textColor = [UIColor whiteColor];
    self.highlightedTextColor = [UIColor lightGrayColor];
    self.hideStatusBarArea = NO;
    
    self.menuStack = [NSMutableArray array];
    
    return self;
}

- (id)initWithItems:(NSArray *)items
{
    self = [self init];
    if (!self)
        return nil;
    _items = items;
    [_menuStack addObject:items];
    _backMenu = [[RESideMenuItem alloc] initWithTitle:@"<" action:nil];
    _songName = [[THLabel alloc] initWithFrame:CGRectMake(60, 12, 200, 20)];
    [_songName setTextColor:[UIColor whiteColor]];
    [_songName setBackgroundColor:[UIColor clearColor]];
    [_songName setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [_songName setShadowColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [_songName setShadowOffset:CGSizeZero];
    [_songName setNumberOfLines:1];
    [_songName setShadowBlur:6.0f];
    _timeLabel = [[THLabel alloc] initWithFrame:CGRectMake(260, 12, 200, 20)];
    [_timeLabel setTextColor:[UIColor whiteColor]];
    [_timeLabel setBackgroundColor:[UIColor clearColor]];
    [_timeLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [_timeLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [_timeLabel setShadowOffset:CGSizeZero];
    [_timeLabel setShadowBlur:3.0f];
    _playPause = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playPause setFrame:CGRectMake(8, 0, 44, 44)];
    [_playPause setBackgroundColor:[UIColor clearColor]];
    [_playPause setImageEdgeInsets:UIEdgeInsetsMake(7, 0, 7, 0)];
    [_playPause setImage:[UIImage imageNamed:@"bigplay.png"] forState:UIControlStateNormal];
    [_playPause setImage:[UIImage imageNamed:@"bigpause.png"] forState:UIControlStateSelected];
    [_playPause addTarget:self action:@selector(playPauseFunc:) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updFunc:)
                                                 name:@"menuUpdate"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updatePlayPause:)
                                                 name:@"updatePlayPause"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBg)
                                                 name:@"newBg"
                                               object:nil];
    [self setBg];
    return self;
}

- (void) setBg {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *bgname = [ud objectForKey:@"bgPic"];
    if (bgname == nil) {
        bgname = @"playerbg1.jpg";
        [ud setValue:bgname forKey:@"bgPic"];
        [ud synchronize];
    }
    UIImage *img = [UIImage imageNamed:bgname];
    img = [img imageWithBrightness:0.19f];
    _backgroundImage = img;
}

- (void)updatePlayPause:(NSNotification *)notification {
    NSLog(@"called updatePlayPause");
    [_playPause setImage:[[notification userInfo] valueForKey:@"image"] forState:UIControlStateNormal];
}

- (void) updFunc: (NSNotification *) note{
    [_songName setText:[note.userInfo objectForKey:@"name"]];
    NSString *time = [NSString stringWithFormat:@"%@ %@", [note.userInfo objectForKey:@"time"], [note.userInfo objectForKey:@"timeLeft"]];
    [_timeLabel setText:time];
  //  BOOL pl = (BOOL)[note.userInfo objectForKey:@"playing"];
  //  [_playPause setSelected:pl];
}

- (void) playPauseFunc:(id) button {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerPlay" object:nil];
}

- (void) showItems:(NSArray *)items
{
    // Animate to deappear
    __typeof (&*self) __weak weakSelf = self;
    weakSelf.tableView.transform = CGAffineTransformScale(_tableView.transform, 0.9, 0.9);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.tableView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.tableView.alpha = 0;
    }];
    
    // Set items and reload
    _items = items;
    [self.tableView reloadData];
    
    // Animate to reappear once reloaded
    weakSelf.tableView.transform = CGAffineTransformScale(_tableView.transform, 1, 1);
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.tableView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.6 animations:^{
        weakSelf.tableView.alpha = 1;
    }];
    
}

- (void)show
{
    if (_isShowing)
        return;
    
    _isShowing = YES;
    
    // keep track of whether or not it was already hidden
    _appIsHidingStatusBar=[[UIApplication sharedApplication] isStatusBarHidden];
    
    if(!_appIsHidingStatusBar)
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    [self performSelector:@selector(showAfterDelay) withObject:nil afterDelay:0.1];
}

- (void)hide
{
    [self restoreFromRect:_screenshotView.frame];
}

- (void)setRootViewController:(UIViewController *)viewController
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    window.rootViewController = viewController;
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    [window bringSubviewToFront:_backgroundView];
    [window bringSubviewToFront:_tableView];
    [window bringSubviewToFront:_screenshotView];
}

- (void)addAnimation:(NSString *)path view:(UIView *)view startValue:(double)startValue endValue:(double)endValue
{
    AccelerationAnimation *animation = [AccelerationAnimation animationWithKeyPath:path
                                                                        startValue:startValue
                                                                          endValue:endValue
                                                                  evaluationObject:[[ExponentialDecayEvaluator alloc] initWithCoefficient:6.0]
                                                                 interstitialSteps:INTERSTITIAL_STEPS];
    animation.removedOnCompletion = NO;
    [view.layer addAnimation:animation forKey:path];
}

//- (void)animate

- (void)showAfterDelay
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    // Take a snapshot
    //
    _screenshotView = [[UIImageView alloc] initWithFrame:CGRectNull];
    _screenshotView.image = [window re_snapshotWithStatusBar:!self.hideStatusBarArea];
    _screenshotView.frame = CGRectMake(0, 0, _screenshotView.image.size.width, _screenshotView.image.size.height);
    _screenshotView.userInteractionEnabled = YES;
    _screenshotView.layer.anchorPoint = CGPointMake(0, 0);
    
    _originalSize = _screenshotView.frame.size;
    
    // Add views
    //
    _backgroundView = [[REBackgroundView alloc] initWithFrame:window.bounds];
    _backgroundView.backgroundImage = _backgroundImage;
    [window addSubview:_backgroundView];
    
    _playerView = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playerView setFrame:CGRectMake(0, 50, 320, 44)];               // initWithFrame:CGRectMake(0, 50, 320, 44)];
    [_playerView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.0]];
    [_playerView addSubview:_playPause];
    [_playerView addSubview:_songName];
    [_playerView addSubview:_timeLabel];
    [_playerView addTarget:self action:@selector(openPl) forControlEvents:UIControlEventTouchUpInside];
    
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, window.frame.size.height)];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView = nil;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, window.frame.size.width, self.verticalOffset)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.alpha = 0;
    [window addSubview:_tableView];
    [window addSubview:_playerView];
    
    [window addSubview:_screenshotView];
    
    [self minimizeFromRect:CGRectMake(0, 0, _originalSize.width, _originalSize.height)];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
    [_screenshotView addGestureRecognizer:panGestureRecognizer];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [_screenshotView addGestureRecognizer:tapGestureRecognizer];
}

- (void)minimizeFromRect:(CGRect)rect
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat m = 0.5 ;
    CGFloat newWidth = _originalSize.width * m;
    CGFloat newHeight = _originalSize.height * m;
    
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.6] forKey:kCATransactionAnimationDuration];
    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:window.frame.size.width - 80.0];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:(window.frame.size.height - newHeight) / 2.0];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:newWidth];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:newHeight];
    
    _screenshotView.layer.position = CGPointMake(window.frame.size.width - 80.0, (window.frame.size.height - newHeight) / 2.0);
    _screenshotView.layer.bounds = CGRectMake(window.frame.size.width - 80.0, (window.frame.size.height - newHeight) / 2.0, newWidth, newHeight);
    [CATransaction commit];
    
    if (_tableView.alpha == 0) {
        __typeof (&*self) __weak weakSelf = self;
        weakSelf.tableView.transform = CGAffineTransformScale(_tableView.transform, 0.9, 0.9);
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.tableView.transform = CGAffineTransformIdentity;
        }];
        
        [UIView animateWithDuration:0.6 animations:^{
            weakSelf.tableView.alpha = 1;
        }];
    }
}

- (void)restoreFromRect:(CGRect)rect
{
    [[UIApplication sharedApplication] setStatusBarHidden:_appIsHidingStatusBar withAnimation:UIStatusBarAnimationNone];
    _screenshotView.userInteractionEnabled = NO;
    while (_screenshotView.gestureRecognizers.count) {
        [_screenshotView removeGestureRecognizer:[_screenshotView.gestureRecognizers objectAtIndex:0]];
    }
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:0.4] forKey:kCATransactionAnimationDuration];
    [self addAnimation:@"position.x" view:_screenshotView startValue:rect.origin.x endValue:0];
    [self addAnimation:@"position.y" view:_screenshotView startValue:rect.origin.y endValue:0];
    [self addAnimation:@"bounds.size.width" view:_screenshotView startValue:rect.size.width endValue:window.frame.size.width];
    [self addAnimation:@"bounds.size.height" view:_screenshotView startValue:rect.size.height endValue:window.frame.size.height];
    
    _screenshotView.layer.position = CGPointMake(0, 0);
    _screenshotView.layer.bounds = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);
    [CATransaction commit];
    [self performSelector:@selector(restoreView) withObject:nil afterDelay:0.4];
    
    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.tableView.alpha = 0;
        weakSelf.tableView.transform = CGAffineTransformScale(_tableView.transform, 0.7, 0.7);
    }];
    
    // restore the status bar to its original state.
    
    _isShowing = NO;
}

- (void)restoreView
{
    __typeof (&*self) __weak weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.screenshotView.alpha = 0;
    } completion:^(BOOL finished) {
        [weakSelf.screenshotView removeFromSuperview];
    }];
    [_backgroundView removeFromSuperview];
    [_tableView removeFromSuperview];
    [_playerView removeFromSuperview];
}

#pragma mark -
#pragma mark Gestures

- (void)panGestureRecognized:(UIPanGestureRecognizer *)sender
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    CGPoint translation = [sender translationInView:window];
	if (sender.state == UIGestureRecognizerStateBegan) {
		_initialX = _screenshotView.frame.origin.x;
	}
	
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat x = translation.x + _initialX;
        CGFloat m = 1 - ((x / window.frame.size.width) * 210/window.frame.size.width);
        CGFloat y = (window.frame.size.height - _originalSize.height * m) / 2.0;
        
        _tableView.alpha = (x + 80.0) / window.frame.size.width;
        
        if (x < 0 || y < 0) {
            _screenshotView.frame = CGRectMake(0, 0, _originalSize.width, _originalSize.height);
        } else {
            _screenshotView.frame = CGRectMake(x, y, _originalSize.width * m, _originalSize.height * m);
        }
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        if ([sender velocityInView:window].x < 0) {
            [self restoreFromRect:_screenshotView.frame];
        } else {
            [self minimizeFromRect:_screenshotView.frame];
        }
    }
}

- (void)tapGestureRecognized:(UITapGestureRecognizer *)sender
{
    [self restoreFromRect:_screenshotView.frame];
}

- (void)openPl
{
    NSLog(@"touched");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
    //[self performSelector:@selector(lateRestore) withObject:nil afterDelay:0.4];
     [self restoreFromRect:_screenshotView.frame];
}

- (void) lateRestore {
    [self restoreFromRect:_screenshotView.frame];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }
    else {
        return 4;
    }
  //  return _items.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *headerView = nil;
	if (section == 1) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
                            (id)[UIColor colorWithRed:(255.0f/255.0f) green:(255.0f/255.0f) blue:(255.0f/255.0f) alpha:0.0f].CGColor,
                            (id)[UIColor colorWithRed:(235.0f/255.0f) green:(235.0f/255.0f) blue:(235.0f/255.0f) alpha:0.0f].CGColor,
                            ];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
		textLabel.text = @"Вконтакте";
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 0.8f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		textLabel.textColor = [UIColor colorWithRed:(225.0f/255.0f) green:(225.0f/255.0f) blue:(225.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(50.0f/255.0f) green:(50.0f/255.0f) blue:(50.0f/255.0f) alpha:0.0f];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(10.0f/255.0f) green:(10.0f/255.0f) blue:(10.0f/255.0f) alpha:0.0f];
		[headerView addSubview:bottomLine];
	}
    if (section == 0) {
        headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
        [headerView setBackgroundColor:[UIColor clearColor]];
    }
	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.itemHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"RESideMenuCell";
    
    RESideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[RESideMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
      //  cell.textLabel.font = self.font;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:24];
        if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
            cell.textLabel.font = self.font;
        }
        cell.textLabel.textColor = self.textColor;
        [cell.textLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.4]];
        [cell.textLabel setShadowOffset:CGSizeZero];
        [cell.textLabel setShadowBlur:8.0f];
        cell.textLabel.highlightedTextColor = self.highlightedTextColor;
    }
    
    
    RESideMenuItem *item = [_items objectAtIndex:indexPath.row];
    if (indexPath.section == 1) item = [_items objectAtIndex:indexPath.row + 3];
    cell.textLabel.text = item.title;
    cell.imageView.image = item.image;
    cell.imageView.highlightedImage = item.highlightedImage;
    cell.horizontalOffset = self.horizontalOffset;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    RESideMenuItem *item;
    if (indexPath.section == 0) {
        item = [_items objectAtIndex:indexPath.row];
    }
    else {
        item = [_items objectAtIndex:indexPath.row + 3];
    }
    
    // Case back on subMenu
    if(_isInSubMenu &&
       indexPath.row==0 &&
       indexPath.section == 0){
        
        [_menuStack removeLastObject];
        if(_menuStack.count==1){
            _isInSubMenu = NO;
        }
        [self showItems:_menuStack.lastObject];
        
        return;
    }
        
    // Case menu with subMenu
    if(item.subItems){
        _isInSubMenu = YES;
        
        // Concat back menu to submenus and show
        NSMutableArray * array = [NSMutableArray arrayWithObject:_backMenu];
        [array addObjectsFromArray:item.subItems];
        [self showItems:array];
        
        // Push new menu on stack
        [_menuStack addObject:array];
    }
    
    if (item.action)
        item.action(self, item);
}

@end
