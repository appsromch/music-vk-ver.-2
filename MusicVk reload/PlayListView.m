//
//  PlayListView.m
//  MusicVk reload
//
//  Created by David Dreval on 04.06.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "PlayListView.h"
@interface PlayListView ()

@end

#pragma mark -
#pragma mark Implementation
@implementation PlayListView
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
        [rightButton addTarget:self action:@selector(editFunc:) forControlEvents:UIControlEventTouchUpInside];
        [rightButton setEnabled:NO];
        UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
        [self.navigationItem setRightBarButtonItem:rightBarButton];
	}
	return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *docDirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    plpath = [NSString stringWithFormat:@"%@/pls.plist", docDirPath];
    playlistArray = [[NSMutableDictionary alloc]initWithContentsOfFile:plpath];
    if (playlistArray == nil) {
        playlistArray = [[NSMutableDictionary alloc] init];
        [playlistArray writeToFile:plpath atomically:YES];
    }
    NSLog(@"%@", playlistArray);
    table = [[UITableView alloc] init];
    [table setDelegate:self];
    [table setDataSource:self];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorColor:[UIColor colorWithWhite:0 alpha:0.05]];
    UIButton *add = [UIButton buttonWithType:UIButtonTypeCustom];
    [add addTarget:self action:@selector(addPlayList) forControlEvents:UIControlEventTouchUpInside];
    [add setBackgroundColor:[UIColor clearColor]];
    [add setTitle:@"Добавить плейлист" forState:UIControlStateNormal];
    [add setFrame:CGRectMake(0, 0, 320, 40)];
    [add.titleLabel setTextColor:[UIColor whiteColor]];
    [add.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:18]];
    [table setTableHeaderView:add];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [table setTableFooterView:footerView];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
    [refreshControl addTarget:self action:@selector(dropViewPulled) forControlEvents:UIControlEventValueChanged];
    [self setView:table];

	// Do any additional setup after loading the view.
}

- (void) addPlayList {
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Введите название"];
    [dialog addButtonWithTitle:@"Cancel"];
    [dialog addButtonWithTitle:@"OK"];
    [dialog setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [dialog show];
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        NSLog(@"%@", tf.text);
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [playlistArray setValue:array forKey:tf.text];
        NSLog(@"%@", playlistArray);
        [playlistArray writeToFile:plpath atomically:YES];
        [table reloadData];
    }
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
    return playlistArray.allKeys.count;
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
    [cell.contentView setTag:indexPath.row];
    cell.textLabel.text = [playlistArray.allKeys objectAtIndex:indexPath.row];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [cell.textLabel setShadowOffset:CGSizeZero];
    [cell.textLabel setShadowBlur:2.0f];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Аудиозаписей: %d", playlistArray.count];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    [cell.detailTextLabel setShadowColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [cell.detailTextLabel setShadowOffset:CGSizeZero];
    [cell.detailTextLabel setShadowBlur:2.0f];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%d", indexPath.row);
    NSString *key = [playlistArray.allKeys objectAtIndex:indexPath.row];
    [playlistArray removeObjectForKey:key];
    [table reloadData];
    [playlistArray writeToFile:plpath atomically:YES];
}

- (void) editFunc: (UIButton *) button {
    if (table.editing == NO) {
        [table setEditing:YES animated:YES];
        [button setTitle:@"Готово" forState:UIControlStateNormal];
    }
    else { [table setEditing:NO animated:YES];
        [button setTitle:@"Плейлисты" forState:UIControlStateNormal];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"selected cell at %@, %f, %f", indexPath, cell.frame.origin.x, cell.frame.origin.y);
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

- (void) dropViewPulled {
    playlistArray = [[NSMutableDictionary alloc]initWithContentsOfFile:plpath];
    NSLog(@"%@", playlistArray);
    [table reloadData];
}

@end
