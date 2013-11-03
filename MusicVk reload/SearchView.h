//
//  SearchView.h
//  MusicVk reload
//
//  Created by David Dreval on 05.09.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"
#import <CoreData/CoreData.h>
#import "RootViewController.h"

@interface SearchView : RootViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, UISearchBarDelegate> {
@private
	RevealBlock _revealBlock;
    UITableView *table;
    ODRefreshControl *refreshControl;
    NSMutableArray *audioArray;
    BOOL searching;
    NSMutableDictionary *dictionaryForConnection;
    NSMutableDictionary *progressViewsForConnection;
    NSMutableDictionary *expectedLength;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *) managedObjectC;

@end
