//
//  ItunesViewController.m
//  MusicVk reload
//
//  Created by David Dreval on 16.07.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "ItunesViewController.h"

@interface ItunesViewController ()

@end

@implementation ItunesViewController
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


- (void)viewDidLoad
{
    [super viewDidLoad];
    MPMediaQuery *query = [[MPMediaQuery alloc] init];
    [query setGroupingType:MPMediaGroupingTitle];
    audioArray = [[NSMutableArray alloc] initWithArray:[query items]];
    NSLog(@"%@", audioArray);
    table = [[UITableView alloc] init];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorColor:[UIColor colorWithWhite:0 alpha:0.05]];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [table setTableFooterView:footerView];
   // refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
   // [refreshControl addTarget:self action:@selector(dropViewPulled) forControlEvents:UIControlEventValueChanged];
    [self setView:table];
	// Do any additional setup after loading the view.
}

#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    [refreshControl endRefreshing];
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0;
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return audioArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    // UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[CustomCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleTableIdentifier];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        [cell setBackgroundColor:[UIColor clearColor]];
    }
    MPMediaItem *item = [audioArray objectAtIndex:indexPath.row];
    NSString *name = [item valueForProperty: MPMediaItemPropertyTitle];
    NSString *art = [item valueForProperty: MPMediaItemPropertyArtist];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [cell.textLabel setText:name];
    [cell.detailTextLabel setText:art];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected cell at %@", indexPath);
    [[NSUserDefaults standardUserDefaults] setObject:@"itunes" forKey:@"window"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"songNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newSong" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:audioArray, @"audioArray", nil]];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)revealSidebar {
	_revealBlock();
}

- (void)saveContext {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

@end
