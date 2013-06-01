//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"
#import "GHPushedViewController.h"
#import "vkLogin.h"
#import "PlayerViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface GHRootViewController ()
- (void)pushViewController;
- (void)revealSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRootViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController;

#pragma mark Memory Management
- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *)managedObjectC {
    if (self = [super initWithNibName:nil bundle:nil]) {
		self.title = @"";
		_revealBlock = [revealBlock copy];
        managedObjectContext = managedObjectC;
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
    table = [[UITableView alloc] init];
    [table setDelegate:self];
    [table setDataSource:self];
    //[table setBackgroundColor:[UIColor colorWithWhite:0.92 alpha:1]];
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorColor:[UIColor colorWithWhite:0 alpha:0.05]];
    allSongsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 18)];
    [allSongsLabel setBackgroundColor:[UIColor clearColor]];
    [allSongsLabel setTextAlignment:NSTextAlignmentCenter];
    [allSongsLabel setTextColor:[UIColor colorWithWhite:0.75 alpha:1]];
    [allSongsLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [table setTableFooterView:allSongsLabel];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
    [refreshControl addTarget:self action:@selector(dropViewPulled) forControlEvents:UIControlEventValueChanged];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *token = [ud objectForKey:@"token"];
    if (!token) {
        NSLog(@"No token");
        vkLogin *vk = [[vkLogin alloc] init];
        [self presentViewController:vk animated:NO completion:nil];
    }
    else {
        NSLog(@"token = %@", token);
        NSString *authString = [NSString stringWithFormat:@"https://api.vk.com/method/getUserSettings?access_token=%@", token];
        NSURL *authURL = [[NSURL alloc] initWithString:authString];
        NSURLRequest *theRequest =
        [NSURLRequest requestWithURL:authURL
                         cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                     timeoutInterval:10.0];
        NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
        
        if (theConnection) {
            rData = nil;
            rData = [NSMutableData data];
        }
    }
    [self performSelector:@selector(settable) withObject:nil afterDelay:0.1];
}

- (void) settable {
    [self setView:table];
}

- (void) dropViewPulled {
    [table reloadData];
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [rData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [rData appendData:data];
    NSLog(@"rData updated");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *json_string = [[NSString alloc] initWithData:rData encoding:NSUTF8StringEncoding];
    NSLog(@"json string = %@", json_string);
    NSRange textRange =[json_string rangeOfString:[NSString stringWithFormat:@"error"]];
   
    if(textRange.location != NSNotFound)
    {
        // AuthViewController *authView = [[AuthViewController alloc] initWithHidden:YES];
        vkLogin *vk = [[vkLogin alloc] init];
        [self presentViewController:vk animated:NO completion:nil];
        //Does contain the substring
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
    return NO;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    [allSongsLabel setText:[NSString stringWithFormat:@"Всего песен: %d", [sectionInfo numberOfObjects]]];
    return [sectionInfo numberOfObjects];
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
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

- (void)cellSwiped:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        UITableViewCell *cell = (UITableViewCell *)gestureRecognizer.view;
        if (cell.contentView.subviews.count == 0) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(320, 0, 0, 44)];
            [view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellAction.png"]]];
            [cell.contentView addSubview:view];
            
            UIButton *saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [saveButton setFrame:CGRectMake(100, 2, 40, 40)];
            [saveButton setImage:[UIImage imageNamed:@"cellSave.png"] forState:UIControlStateNormal];
            [saveButton addTarget:self action:@selector(saveFunc) forControlEvents:UIControlEventTouchUpInside];
            [saveButton setShowsTouchWhenHighlighted:YES];
            [view addSubview:saveButton];
            
            UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [playButton setFrame:CGRectMake(50, 2, 40, 40)];
            [playButton setImage:[UIImage imageNamed:@"cellPlay.png"] forState:UIControlStateNormal];
            [playButton addTarget:self action:@selector(playFunc) forControlEvents:UIControlEventTouchUpInside];
            [playButton setShowsTouchWhenHighlighted:YES];
            [view addSubview:playButton];
            
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
    if (cell.contentView.subviews.count > 0) {
        UIView *view = [cell.contentView.subviews objectAtIndex:0];
        [UIView animateWithDuration:0.5 animations:^{
            [view setFrame:CGRectMake(320, 0, 0, 44)];
        } completion:^(BOOL fin) {
            [view removeFromSuperview];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"saved" forKey:@"window"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"songNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newSong" object:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark music methods

- (void) saveFunc {
    
}

- (void) playFunc {
    
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
    [fetchRequest setFetchBatchSize:20];
    
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
 
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller  {
 // In the simplest, most efficient, case, reload the table view.
    [table reloadData];
    [allSongsLabel setText:[NSString stringWithFormat:@"Всего песен: %d", [[self.fetchedResultsController fetchedObjects] count]]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[managedObject valueForKey:@"title"] description];
  //  [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setBackgroundColor:[UIColor clearColor]];
    cell.detailTextLabel.text = [[managedObject valueForKey:@"artist"] description];
    [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [cell.detailTextLabel setTextColor:[UIColor colorWithWhite:1 alpha:0.7]];
    [cell.detailTextLabel setBackgroundColor:[UIColor clearColor]];
}

- (void)insertNewObject
{
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                                      inManagedObjectContext:context];
    
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    [newManagedObject setValue:@"iMaladec" forKey:@"note"];
    
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

@end
