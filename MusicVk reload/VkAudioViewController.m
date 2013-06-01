//
//  VkAudioViewController.m
//  MusicVk reload
//
//  Created by David Dreval on 11.02.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import "VkAudioViewController.h"
#import "GHPushedViewController.h"
#import "vkLogin.h"
#import "customNSURLConnection.h"

#pragma mark -
#pragma mark Private Interface
@interface VkAudioViewController ()
- (void)pushViewController;
- (void)revealSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation VkAudioViewController
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

#pragma mark UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	self.view.backgroundColor = [UIColor whiteColor];
    dictionaryForConnection = [[NSMutableDictionary alloc] init];
    progressViewsForConnection = [[NSMutableDictionary alloc] init];
    expectedLength = [[NSMutableDictionary alloc] init];
    audioArray = [[NSMutableArray alloc] init];
    table = [[UITableView alloc] init];
    [table setDelegate:self];
    [table setDataSource:self];
    //[table setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1]];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorColor:[UIColor colorWithWhite:0 alpha:0.05]];
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    [footerView setBackgroundColor:[UIColor clearColor]];
    [table setTableFooterView:footerView];
    UISwipeGestureRecognizer* sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(cellSwiped:)];
    [sgr setDirection:UISwipeGestureRecognizerDirectionLeft];
    [table addGestureRecognizer:sgr];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
    [refreshControl addTarget:self action:@selector(dropViewPulled) forControlEvents:UIControlEventValueChanged];
    [self setView:table];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud objectForKey:@"token"];
    if (!token) {
        NSLog(@"No token");
        vkLogin *vk = [[vkLogin alloc] init];
        [self presentViewController:vk animated:NO completion:nil];
    }
    else {
        NSString *authString = [NSString stringWithFormat:@"https://api.vk.com/method/audio.get?access_token=%@", token];
        NSURL *authURL = [[NSURL alloc] initWithString:authString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authURL];
        CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:[NSString stringWithFormat:@"rData"]];
        
        if (connection) {
            [dictionaryForConnection setObject:[NSMutableData data] forKey:connection.tag];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
        
        NSLog(@"token = %@", token);
    }
}

- (void) dropViewPulled {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud objectForKey:@"token"];
    if (!token) {
        NSLog(@"No token");
        vkLogin *vk = [[vkLogin alloc] init];
        [self presentViewController:vk animated:NO completion:nil];
    }
    else {
        NSString *authString = [NSString stringWithFormat:@"https://api.vk.com/method/audio.get?access_token=%@", token];
        NSURL *authURL = [[NSURL alloc] initWithString:authString];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:authURL];
        CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:[NSString stringWithFormat:@"rData"]];
        
        if (connection) {
            [dictionaryForConnection setObject:[NSMutableData data] forKey:connection.tag];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        }
    }
}

#pragma mark Private Methods
- (void)pushViewController {
	NSString *vcTitle = [self.title stringByAppendingString:@" - Pushed"];
	UIViewController *vc = [[GHPushedViewController alloc] initWithTitle:vcTitle];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)revealSidebar {
	_revealBlock();
}

#pragma mark NSURLConnection methods

- (void)connection:(CustomURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    [dataForConnection setLength:0];
    
    if (![connection.tag isEqualToString:@"rData"]) {
        [expectedLength setObject:[NSString stringWithFormat:@"%lld",[response expectedContentLength]] forKey:connection.tag];
    }
}

- (void)connection:(CustomURLConnection *)connection didReceiveData:(NSData *)data
{
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    [dataForConnection appendData:data];
    if (![connection.tag isEqualToString:@"rData"]) {
        float r = [dataForConnection length];
        float rlength = [[expectedLength objectForKey:connection.tag] floatValue];
        NSNumber *prsnt = [NSNumber numberWithFloat: (r/rlength)];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self progressAnimate:connection.tag percent:prsnt.floatValue];
        });
  }
}

- (void) progressAnimate:(NSString *)tag percent:(float) prsnt {
    UIProgressView *progress = [progressViewsForConnection objectForKey:tag];
    [progress setProgress:prsnt animated:YES];
}

- (void)connection:(CustomURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(CustomURLConnection *)connection
{
    NSMutableData *dataForConnection = [self dataForConnection:(CustomURLConnection*)connection];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([connection.tag isEqualToString:@"rData"]) {
        NSString *json_string = [[NSString alloc] initWithData:dataForConnection encoding:NSUTF8StringEncoding];
        NSRange textRange =[json_string rangeOfString:[NSString stringWithFormat:@"error"]];
        if(textRange.location != NSNotFound)
        {
            vkLogin *vk = [[vkLogin alloc] init];
            [self presentViewController:vk animated:NO completion:nil];
            //Does contain the substring
        }
        
        NSError *error;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:dataForConnection options:kNilOptions error:&error];
        audioArray = [NSMutableArray arrayWithArray:[jsonDict objectForKey:@"response"]];
        //NSLog(@"audio Array = %@", audioArray);
        [refreshControl endRefreshing];
        [table reloadData];
    }
    else {
        NSLog(@"loaded data = %lu", (unsigned long)dataForConnection.length);
        UIProgressView *pview = [progressViewsForConnection objectForKey:connection.tag];
        [pview removeFromSuperview];
        NSDictionary *dict = [audioArray objectAtIndex:connection.tag.intValue];
        NSString *name = [dict objectForKey:@"title"];
        NSString *artist = [dict objectForKey:@"artist"];
        [self insertNewObject:dataForConnection withTitle:name andArtist:artist];
    }
    [dictionaryForConnection removeObjectForKey:connection.tag];
    [progressViewsForConnection removeObjectForKey:connection.tag];
    [expectedLength removeObjectForKey:connection.tag];
    NSLog(@"%d, %d, %d", dictionaryForConnection.count, progressViewsForConnection.count, expectedLength.count);
}

#pragma mark Table methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 44.0;
    return height;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [audioArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleTableIdentifier];
        //[cell.contentView setBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1]];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
        
        //  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 1)];
        //  [line setBackgroundColor:[UIColor whiteColor]];
        //  [cell.contentView addSubview:line];
    }
    
    NSDictionary *dict = [audioArray objectAtIndex:indexPath.row];
    NSString *name = [dict objectForKey:@"title"];
    name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    cell.textLabel.text = name;
   // [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
    NSString *art = [dict objectForKey:@"artist"];
    art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    //  [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];

    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
    
    [cell.textLabel setText:name];
    [cell.detailTextLabel setText:art];
    if ([cell.contentView.subviews count] > 2) {
        UIView *view = [cell.contentView.subviews objectAtIndex:2];
        if (view.tag != indexPath.row) [view removeFromSuperview];
    }
  //  NSLog(@"%d, %@", indexPath.row, cell.contentView.subviews);
    return cell;
    
}

- (void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint location = [gestureRecognizer locationInView:table];
        NSIndexPath *indexPath = [table indexPathForRowAtPoint:location];
        UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO];
        [cell setHighlighted:NO];
       // NSLog(@"swiped 1 %@", cell.contentView.subviews);
        if (cell.contentView.subviews.count == 2) {
            NSLog(@"swiped 2");
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 0, 44)];
            [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellAction.png"]]];
            [view setTag:indexPath.row];
            [cell.contentView addSubview:view];
            
            UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [saveButton setFrame:CGRectMake(100, 2, 30, 30)];
            [saveButton setImage:[UIImage imageNamed:@"cellSave.png"] forState:UIControlStateNormal];
            [saveButton addTarget:self action:@selector(saveFunc:) forControlEvents:UIControlEventTouchUpInside];
            [saveButton setTag:indexPath.row];
            [saveButton setShowsTouchWhenHighlighted:YES];
            [view addSubview:saveButton];
            
            UILabel *saveLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 30, 40, 12)];
            [saveLabel setBackgroundColor:[UIColor clearColor]];
            [saveLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
            [saveLabel setTextAlignment:NSTextAlignmentCenter];
            [saveLabel setText:@"Save"];
            [saveLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
            [saveLabel setNumberOfLines:1];
            [saveLabel setShadowColor:[UIColor blackColor]];
            [saveLabel setShadowOffset:CGSizeMake(0, 1)];
            [view addSubview:saveLabel];
            
            UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [playButton setFrame:CGRectMake(50, 2, 30, 30)];
            [playButton setTag:indexPath.row];
            [playButton setImage:[UIImage imageNamed:@"cellPlay.png"] forState:UIControlStateNormal];
            [playButton addTarget:self action:@selector(playFunc:) forControlEvents:UIControlEventTouchUpInside];
            [playButton setShowsTouchWhenHighlighted:YES];
            [view addSubview:playButton];
            
            UILabel *playLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 30, 40, 12)];
            [playLabel setBackgroundColor:[UIColor clearColor]];
            [playLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
            [playLabel setTextAlignment:NSTextAlignmentCenter];
            [playLabel setText:@"Play"];
            [playLabel setTextColor:[UIColor colorWithWhite:0.9 alpha:1]];
            [playLabel setNumberOfLines:1];
            [playLabel setShadowColor:[UIColor blackColor]];
            [playLabel setShadowOffset:CGSizeMake(0, 1)];
            [view addSubview:playLabel];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [UIView animateWithDuration:0.5 animations:^{
                [view setFrame:CGRectMake(170, 0, 150, 44)];
            }];
        }
        //..
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected cell at %@", indexPath);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.contentView.subviews.count > 2) {
        UIView *view = [cell.contentView.subviews objectAtIndex:2];
        [UIView animateWithDuration:0.5 animations:^{
            [view setFrame:CGRectMake(320, 0, 0, 44)];
        } completion:^(BOOL fin) {
            [view removeFromSuperview];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }];
    }
    else {
        [self goToPlayer:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark music methods

- (void) saveFunc: (UIButton *) button {
    NSLog(@"called save %d", button.tag);
    NSDictionary *dict = [audioArray objectAtIndex:button.tag];
    UIProgressView *progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [progress setBackgroundColor:[UIColor clearColor]];
    [progress setTrackTintColor:[UIColor clearColor]];
    [progress setAlpha:0.5];
    [progress setFrame:CGRectMake(15, 31, 133, 11)];
    [progress setProgress:0];
    [progress setHidden:NO];
    [button.superview insertSubview:progress atIndex:0];
   // dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSURL *songURL = [[NSURL alloc] initWithString:[dict objectForKey:@"url"]];
    NSString *tag = [NSString stringWithFormat:@"%d", button.tag];
    [self startAsyncLoad:songURL tag:tag progress:progress];
   // });
}

- (void)startAsyncLoad:(NSURL*)url tag:(NSString*)tag progress:(UIProgressView *) progress {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    CustomURLConnection *connection = [[CustomURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES tag:tag];
    
    if (connection) {
        [dictionaryForConnection setObject:[NSMutableData data] forKey:connection.tag];
        [progressViewsForConnection setObject:progress forKey:connection.tag];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (NSMutableData*)dataForConnection:(CustomURLConnection*)connection {
    NSMutableData *data = [dictionaryForConnection objectForKey:connection.tag];
    return data;
}

- (void) playFunc:(id) sender {
    UIButton *butt = sender;
    [self goToPlayer:butt.tag];
}

- (void) goToPlayer: (int) row {
    [[NSUserDefaults standardUserDefaults] setObject:@"audios" forKey:@"window"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", row] forKey:@"songNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newSong" object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:audioArray, @"audioArray", nil]];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (fetchedResultsController != nil) {
        return fetchedResultsController;
    }
    
    // Set up the fetched results controller.
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:0];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	    /*
	     Replace this implementation with code to handle the error appropriately.
         
	     abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
	     */
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return fetchedResultsController;
}
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
     [table reloadData];
 }

- (void)insertNewObject:(NSData *)data withTitle:(NSString *)name andArtist:(NSString *)art {
    name = [name stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    name = [name stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    name = [name stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    name = [name stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    art = [art stringByReplacingOccurrencesOfString:@"&#39;" withString:@"'"];
    art = [art stringByReplacingOccurrencesOfString:@"&#33;" withString:@"!"];
    art = [art stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    art = [art stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    
    for (NSManagedObject *obj in self.fetchedResultsController.fetchedObjects) {
        if ([[obj valueForKey:@"title"] isEqualToString:name] && [[obj valueForKey:@"artist"] isEqualToString:art]) {
            NSLog(@"already exist");
            return;
        }
    }
    
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:context];
    NSString *randomUUID = [self GetUUID];
    randomUUID = [randomUUID stringByAppendingPathExtension:@"mp3"];
    NSLog(@"%@", randomUUID);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:randomUUID];
    [data writeToFile:filePath atomically:YES];
    
    [newManagedObject setValue:filePath forKey:@"filepath"];
    [newManagedObject setValue:name forKey:@"title"];
    [newManagedObject setValue:art forKey:@"artist"];
    
    [self saveContext];
}

- (void)saveContext {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
