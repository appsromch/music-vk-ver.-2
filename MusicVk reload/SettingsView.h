//
//  SettingsView.h
//  MusicVk reload
//
//  Created by David Dreval on 05.09.13.
//  Copyright (c) 2013 David Dreval. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GHRootViewController.h"
#import <CoreData/CoreData.h>
#import "RootViewController.h"

@interface SettingsView : RootViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, UIAlertViewDelegate> {
@private
	RevealBlock _revealBlock;
    UITableView *table;
}
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

- (id)initWithTitle:(NSString *)title withRevealBlock:(RevealBlock)revealBlock andManagedObject:(NSManagedObjectContext *) managedObjectC;

@end
