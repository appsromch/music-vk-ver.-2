//
//  GHRootViewController.h
//  GHSidebarNav
//
//  Created by Greg Haines on 11/20/11.
//

#import <Foundation/Foundation.h>
#import "ODRefreshControl.h"
#import <CoreData/CoreData.h>

typedef void (^RevealBlock)();

@interface GHRootViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSURLConnectionDelegate, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
@private
	RevealBlock _revealBlock;
    UITableView *table;
    ODRefreshControl *refreshControl;
    NSMutableData *rData;
    BOOL searching;
    NSMutableArray *filteredArray;
    UILabel *allSongsLabel;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *)managedObjectC;

@end
