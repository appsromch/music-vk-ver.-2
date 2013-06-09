//
//  GHMenuViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 1/3/12.
//  Copyright (c) 2012 Greg Haines. All rights reserved.
//

#import "GHMenuViewController.h"
#import "GHMenuCell.h"
#import "GHRevealViewController.h"
#import <QuartzCore/QuartzCore.h>


#pragma mark -
#pragma mark Implementation
@implementation GHMenuViewController {
	GHRevealViewController *_sidebarVC;
	UISearchBar *_searchBar;
	UITableView *_menuTableView;
	NSArray *_headers;
	NSArray *_controllers;
	NSArray *_cellInfos;
    UIViewController *_player;
    UILabel *songArtist;
    UILabel *songTitle;
    UIButton *playpause;
    UIButton *note;
}

#pragma mark Memory Management
- (id)initWithSidebarViewController:(GHRevealViewController *)sidebarVC 
					  withSearchBar:(UISearchBar *)searchBar 
						withHeaders:(NSArray *)headers 
					withControllers:(NSArray *)controllers 
					  withCellInfos:(NSArray *)cellInfos
                         withPlayer:(UIViewController *)player {
	if (self = [super initWithNibName:nil bundle:nil]) {
		_sidebarVC = sidebarVC;
		_searchBar = searchBar;
		_headers = headers;
		_controllers = controllers;
		_cellInfos = cellInfos;
		_player = player;
		_sidebarVC.sidebarViewController = self;
		_sidebarVC.contentViewController = _controllers[0][0];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moveSideBar)
                                                     name:@"openPlayer"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLabel:)
                                                     name:@"updateSideBarLabel"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updatePlayPause:)
                                                     name:@"updatePlayPause"
                                                   object:nil];
        
	}
	return self;
}

#pragma mark UIViewController
- (void)viewDidLoad {
	[super viewDidLoad];
    UIView *view = [[UIView alloc] init];
    view.frame = CGRectMake(0, 0, 300, 44);
    view.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    CAGradientLayer *gradientS = [CAGradientLayer layer];
    gradientS.frame = CGRectMake(0, 0, 320, 44);
    gradientS.colors = @[
                         (id)[UIColor colorWithRed:(45.0f/255.0f) green:(47.0f/255.0f) blue:(51.0f/255.0f) alpha:1.0f].CGColor,
                         (id)[UIColor colorWithRed:(30.0f/255.0f) green:(32.0f/255.0f) blue:(36.0f/255.0f) alpha:1.0f].CGColor,
                         ];
    [view.layer insertSublayer:gradientS atIndex:0];
    view.layer.shadowColor = (__bridge CGColorRef)([UIColor blackColor]);
    view.layer.shadowOffset = CGSizeMake(0, 1);
    view.layer.shadowOpacity = 1.0f;
    view.layer.shadowRadius = 5.0f;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 300, 1)];
    [line setBackgroundColor:[UIColor colorWithWhite:0.04 alpha:1]];
    [view addSubview:line];
	self.view.frame = CGRectMake(0.0f, 0.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	
	[self.view addSubview:view];
	[self addButtons:view];
    
    isPlayer = NO;
    
	_menuTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 44.0f, kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds))
												  style:UITableViewStylePlain];
	_menuTableView.delegate = self;
	_menuTableView.dataSource = self;
	_menuTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	_menuTableView.backgroundColor = [UIColor clearColor];
	_menuTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_menuTableView];
	[self selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

- (void)addButtons: (UIView *)view {
    note = [UIButton buttonWithType:UIButtonTypeCustom];
    [note setFrame:CGRectMake(25, -90, 150, 130)];
    [note setBackgroundColor:[UIColor clearColor]];
    [note setShowsTouchWhenHighlighted:YES];
    [note setHidden:YES];
    [note addTarget:self action:@selector(noteButtonFunc) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:note];
    
    songArtist = [[UILabel alloc] initWithFrame:CGRectMake(25, 92, 200, 22)];
    [songArtist setBackgroundColor:[UIColor clearColor]];
    [songArtist setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [songArtist setTextAlignment:NSTextAlignmentLeft];
    [songArtist setText:@""];
    [songArtist setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [songArtist setNumberOfLines:1];
    [songArtist setShadowColor:[UIColor blackColor]];
    [songArtist setShadowOffset:CGSizeMake(0, 1)];
    
    songTitle = [[UILabel alloc] initWithFrame:CGRectMake(25, 114, 200, 22)];
    [songTitle setBackgroundColor:[UIColor clearColor]];
    [songTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
    [songTitle setTextAlignment:NSTextAlignmentLeft];
    [songTitle setText:@""];
    [songTitle setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
    [songTitle setNumberOfLines:1];
    [songTitle setShadowColor:[UIColor blackColor]];
    [songTitle setShadowOffset:CGSizeMake(0, 1)];
    
    [note addSubview:songArtist];
    [note addSubview:songTitle];
    
    playpause = [UIButton buttonWithType:UIButtonTypeCustom];
    [playpause setFrame:CGRectMake(5, 0, 40, 40)];
    [playpause setBackgroundColor:[UIColor clearColor]];
    [playpause setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    [playpause setImageEdgeInsets:UIEdgeInsetsMake(12, 10, 10, 10)];
    [playpause addTarget:self action:@selector(playpauseFunc) forControlEvents:UIControlEventTouchUpInside];
    [playpause setShowsTouchWhenHighlighted:YES];
    [view addSubview:playpause];
    
    /*    UIButton *rwd = [UIButton buttonWithType:UIButtonTypeCustom];
    [rwd setFrame:CGRectMake(130, 0, 40, 44)];
    [rwd setBackgroundColor:[UIColor clearColor]];
    [rwd setImage:[UIImage imageNamed:@"reward.png"] forState:UIControlStateNormal];
    [rwd setImageEdgeInsets:UIEdgeInsetsMake(12, 10, 10, 10)];
    [rwd addTarget:self action:@selector(rwdFunc) forControlEvents:UIControlEventTouchUpInside];
    [rwd setShowsTouchWhenHighlighted:YES];
    [view addSubview:rwd];
    
    UIButton *fwd = [UIButton buttonWithType:UIButtonTypeCustom];
    [fwd setFrame:CGRectMake(210, 0, 40, 44)];
    [fwd setBackgroundColor:[UIColor clearColor]];
    [fwd setImage:[UIImage imageNamed:@"forward.png"] forState:UIControlStateNormal];
    [fwd setImageEdgeInsets:UIEdgeInsetsMake(12, 10, 10, 10)];
    [fwd addTarget:self action:@selector(rwdFunc) forControlEvents:UIControlEventTouchUpInside];
    [fwd setShowsTouchWhenHighlighted:YES];
    [view addSubview:fwd]; */
}

- (void)playerOpen {
    if (note.hidden) {
        [note setHidden:NO];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _sidebarVC.contentViewController = _player;
        [_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
        [_menuTableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
    });
}

- (void)updateLabel:(NSNotification *)notification {
    [songTitle setText:[[notification userInfo] valueForKey: @"title"]];
    [songArtist setText:[[notification userInfo] valueForKey:@"artist"]];
    
}

- (void)updatePlayPause:(NSNotification *)notification {
    NSLog(@"called updatePlayPause");
    [playpause setImage:[[notification userInfo] valueForKey:@"image"] forState:UIControlStateNormal];
}

- (void) moveSideBar {
    [_sidebarVC toggleSidebar:YES duration:kGHRevealSidebarDefaultAnimationDuration];
    [self performSelector:@selector(playerOpen) withObject:nil afterDelay:0.2];
}

- (void) noteButtonFunc {
    if (isPlayer) {
        isPlayer = NO;
        [_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
        [_menuTableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    else {
        isPlayer = YES;
        _sidebarVC.contentViewController = _player;
        [_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
        [_menuTableView selectRowAtIndexPath:nil animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)playpauseFunc {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerPlay" object:nil];
}

- (void) rwdFunc {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerRwd" object:nil];
}

- (void) fwdFunc {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerFwd" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
	self.view.frame = CGRectMake(0.0f, 0.0f,kGHRevealSidebarWidth, CGRectGetHeight(self.view.bounds));
	[_searchBar sizeToFit];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return (orientation == UIInterfaceOrientationPortraitUpsideDown)
		? (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
		: YES;
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _headers.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)_cellInfos[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"GHMenuCell";
    GHMenuCell *cell = (GHMenuCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GHMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	NSDictionary *info = _cellInfos[indexPath.section][indexPath.row];
	cell.textLabel.text = info[kSidebarCellTextKey];
	cell.imageView.image = info[kSidebarCellImageKey];
    cell.imageView.highlightedImage = info[kSidebarCellHighlightedImageKey];
    return cell;
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (_headers[section] == [NSNull null]) ? 0.0f : 21.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSObject *headerText = _headers[section];
	UIView *headerView = nil;
	if (headerText != [NSNull null]) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 21.0f)];
		CAGradientLayer *gradient = [CAGradientLayer layer];
		gradient.frame = headerView.bounds;
		gradient.colors = @[
			(id)[UIColor colorWithRed:(40.0f/255.0f) green:(40.0f/255.0f) blue:(40.0f/255.0f) alpha:1.0f].CGColor,
			(id)[UIColor colorWithRed:(35.0f/255.0f) green:(35.0f/255.0f) blue:(35.0f/255.0f) alpha:1.0f].CGColor,
		];
		[headerView.layer insertSublayer:gradient atIndex:0];
		
		UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 12.0f, 5.0f)];
		textLabel.text = (NSString *) headerText;
		textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:([UIFont systemFontSize] * 0.8f)];
		textLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		textLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
		textLabel.textColor = [UIColor colorWithRed:(125.0f/255.0f) green:(125.0f/255.0f) blue:(125.0f/255.0f) alpha:1.0f];
		textLabel.backgroundColor = [UIColor clearColor];
		[headerView addSubview:textLabel];
		
		UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		topLine.backgroundColor = [UIColor colorWithRed:(50.0f/255.0f) green:(50.0f/255.0f) blue:(50.0f/255.0f) alpha:1.0f];
		[headerView addSubview:topLine];
		
		UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 21.0f, [UIScreen mainScreen].bounds.size.height, 1.0f)];
		bottomLine.backgroundColor = [UIColor colorWithRed:(10.0f/255.0f) green:(10.0f/255.0f) blue:(10.0f/255.0f) alpha:1.0f];
		[headerView addSubview:bottomLine];
	}
	return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
	[_sidebarVC toggleSidebar:NO duration:kGHRevealSidebarDefaultAnimationDuration];
    isPlayer = NO;
}

#pragma mark Public Methods
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition {
        NSLog(@"did selected");
	[_menuTableView selectRowAtIndexPath:indexPath animated:animated scrollPosition:scrollPosition];
	if (scrollPosition == UITableViewScrollPositionNone) {
		[_menuTableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:animated];
	}
	_sidebarVC.contentViewController = _controllers[indexPath.section][indexPath.row];
}

@end
