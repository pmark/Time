//
//  ClocksTableViewController.h
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddClockViewController.h"

@interface ClocksTableViewController : UIViewController <AddClockDelegate, NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    NSArray *m_clocks;
    NSTimer *timer;
    NSInteger activeClockIndex;
    NSDate *viewDate;

@private
    NSFetchedResultsController *fetchedResultsController;
    NSManagedObjectContext *managedObjectContext;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

- (BOOL)aClockIsTicking;
- (void)startTimer;
- (void)stopTimer;
- (IBAction)swipedRight:(id)sender;
- (IBAction)swipedLeft:(id)sender;

@end
