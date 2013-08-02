//
//  PlayListView.h
//  MusicVk reload
//
//  Created by David Dreval on 04.06.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"
#import <CoreData/CoreData.h>
#import "RootViewController.h"

@interface PlayListView : RootViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
@private
	RevealBlock _revealBlock;
    UITableView *table;
    ODRefreshControl *refreshControl;
    NSMutableArray *audioArray;
    NSMutableDictionary *playlistArray;
    NSString *plpath;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *) managedObjectC;

@end
