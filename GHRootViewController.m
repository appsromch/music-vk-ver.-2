//
//  GHRootViewController.m
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import "GHRootViewController.h"
#import "GHPushedViewController.h"
#import "customSearchBar.h"
#import "vkLogin.h"
#import "PlayerViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface GHRootViewController ()
@property customSearchBar *searchBar;
- (void)pushViewController;
- (void)revealSidebar;
@end


#pragma mark -
#pragma mark Implementation
@implementation GHRootViewController
@synthesize managedObjectContext;
@synthesize fetchedResultsController, searchBar;

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
        [rightButton addTarget:self action:@selector(editFunc:) forControlEvents:UIControlEventTouchUpInside];
        searching = NO;
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
    [table setBackgroundColor:[UIColor clearColor]];
    [table setSeparatorColor:[UIColor colorWithWhite:0 alpha:0.05]];
    allSongsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 18)];
    [allSongsLabel setBackgroundColor:[UIColor clearColor]];
    [allSongsLabel setTextAlignment:NSTextAlignmentCenter];
    [allSongsLabel setTextColor:[UIColor colorWithWhite:0.75 alpha:1]];
    [allSongsLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:12]];
    [table setTableFooterView:allSongsLabel];
    
    searchBar = [[customSearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
    searchBar.delegate = self;
    table.tableHeaderView = searchBar;
    
    [table setContentOffset:CGPointMake(0,30)];
  //  refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
  //  [refreshControl addTarget:self action:@selector(dropViewPulled) forControlEvents:UIControlEventValueChanged];
    
    filteredArray = [[NSMutableArray alloc] init];
    
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

- (void) editFunc: (UIButton *) button {
    if (table.editing == NO) {
        [table setEditing:YES animated:YES];
        [button setTitle:@"Готово" forState:UIControlStateNormal];
    }
    else { [table setEditing:NO animated:YES];
        [button setTitle:@"Сохраненные" forState:UIControlStateNormal];
    }
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
        vkLogin *vk = [[vkLogin alloc] init];
        [self presentViewController:vk animated:NO completion:nil];
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
    if (searching)
        return [filteredArray count];
    else {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        [allSongsLabel setText:[NSString stringWithFormat:@"Всего песен: %d", [sectionInfo numberOfObjects]]];
        return [sectionInfo numberOfObjects];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *SimpleTableIdentifier = @"SimpleTableIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SimpleTableIdentifier];
        [cell.contentView setBackgroundColor:[UIColor clearColor]];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected cell at %@", indexPath);
/*    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.contentView.subviews.count > 0) {
        UIView *view = [cell.contentView.subviews objectAtIndex:0];
        [UIView animateWithDuration:0.5 animations:^{
            [view setFrame:CGRectMake(320, 0, 0, 44)];
        } completion:^(BOOL fin) {
            [view removeFromSuperview];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }];
    } */
    if (searching) {
        NSInteger numbr = [self.fetchedResultsController.fetchedObjects indexOfObject:[filteredArray objectAtIndex:indexPath.row]];
        [[NSUserDefaults standardUserDefaults] setObject:@"saved" forKey:@"window"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", numbr] forKey:@"songNumber"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newSong" object:nil];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
    [[NSUserDefaults standardUserDefaults] setObject:@"saved" forKey:@"window"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", indexPath.row] forKey:@"songNumber"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"openPlayer" object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newSong" object:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark music methods

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%d", indexPath.row);
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSError *error;
    [manager removeItemAtPath:[[managedObject valueForKey:@"filepath"]description] error:&error];
    if (error != nil) NSLog(@"error = %@", error);
    [[self.fetchedResultsController managedObjectContext] deleteObject:managedObject];
    [self saveContext];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (searching) {
        NSManagedObject *managedObject = [filteredArray objectAtIndex:indexPath.row];
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
    else {
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
}

- (void)saveContext {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark serach

- (void) searchBarTextDidBeginEditing:(UISearchBar *)theSearchBar {
  //  table.scrollEnabled = NO;
    searchBar.showsCancelButton = NO;
    searching = YES;
    [self searchBar:searchBar textDidChange:searchBar.text];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)theSearchBar  {
    searchBar.showsCancelButton = NO;
    searching = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    table.scrollEnabled = YES;
    [table reloadData];
}

- (void)searchBar:(UISearchBar *)theSearchBar textDidChange:(NSString *)searchText {
    
    //Remove all objects first.
    [filteredArray removeAllObjects];
    
    if([searchText length] > 0) {
        table.scrollEnabled = YES;
        searching = YES;
        [self searchTableView];
    }
    else {
        searching = NO;
    }
    
    [table reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    if (![theSearchBar.text isEqualToString:@""]) {
        [self searchTableView];
        [searchBar resignFirstResponder];
    }
    else {
        searching = NO;
        [searchBar resignFirstResponder];
        [table reloadData];
    }
    
}

- (void) searchTableView {
    
    NSString *searchText = searchBar.text;
    // NSMutableArray *searchArray = [[NSMutableArray alloc] initWithArray:finalArray];
    
    for (NSManagedObject *managedObject in self.fetchedResultsController.fetchedObjects) {
        NSString *sTemp = [[managedObject valueForKey:@"title"] description];
        NSRange titleResultsRange = [sTemp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        NSString *Temp = [[managedObject valueForKey:@"artist"] description];
        NSRange titleRes = [Temp rangeOfString:searchText options:NSCaseInsensitiveSearch];
        if (titleResultsRange.length > 0 || titleRes.length > 0) {
            [filteredArray addObject:managedObject];
        }
    }
}

@end
