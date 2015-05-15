//
//  ClocksTableViewController.m
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClocksTableViewController.h"
#import "Clock.h"
#import "ClockDetailViewController.h"
#import "DayChartViewController.h"
#import "AppDelegate.h"
#import "TimeEntry.h"
#import "Constants.h"

#define NO_ACTIVE_CLOCK -1

@implementation ClocksTableViewController

@synthesize tableView;
@synthesize fetchedResultsController;
@synthesize managedObjectContext;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (CGFloat)totalMinutesOnDate:(NSDate*)date
{
    CGFloat total = 0.0;
    
    for (Clock *clock in m_clocks)
    {
        total += [clock minutesOnDate:date];
    }
    
    return total;    
}

- (CGFloat)totalMinutesToday
{
    CGFloat total = 0.0;
    
    for (Clock *clock in m_clocks)
    {
        total += [clock minutesToday];
    }
    
    return total;    
}

- (NSArray *)clocksWithMinutes
{
    NSMutableArray *clocks = [NSMutableArray array];
    
    for (Clock *clock in m_clocks)
    {
        CGFloat dayMinutes = [clock minutesOnDate:viewDate];
        
//        NSLog(@"%@ has %.2f minutes from %i entries\n\n", 
//              clock.name, 
//              minutesToday, 
//              [clock.timeEntries count]);
        
        if (dayMinutes > 0.0)
        {
            [clocks addObject:clock];
        }
    }
    
    return clocks;
}

- (NSInteger) numberOfClocksWithMinutes
{
    return [[self clocksWithMinutes] count];
}

- (NSString *)s:(NSInteger)i
{
    return (i == 1) ? @"" : @"s";
}

- (void)setHeader
{
    NSString *date = [Clock formattedDate:viewDate];
    
    NSString *headerTitle = @"";
    NSInteger clockCount = [self numberOfClocksWithMinutes];    

    if (clockCount > 0)
    {
        CGFloat totalMinutes = [self totalMinutesOnDate:viewDate];
        NSString *clockedTime;
        
        if (totalMinutes < 60)
        {
            clockedTime = [NSString stringWithFormat:@"%i minute%@", 
                           (int)totalMinutes, 
                           [self s:totalMinutes]];
        }
        else
        {
            clockedTime = [Clock minutesFormattedAsTime:totalMinutes showSeconds:NO];
        }
        
        headerTitle = [NSString stringWithFormat:@"%@ on %i clock%@",
                       clockedTime, 
                       clockCount,
                       [self s:clockCount]];
    }
    else
    {
        headerTitle = @"No clocks";
    }
    
    if ([Clock dateIsToday:viewDate] && clockCount < 1)
    {
        if ([m_clocks count] == 0)
        {
            headerTitle =  @"Add a clock \u2192";
        }
        else
        {
            headerTitle = @"Tap a clock to start it";
        }
    }
    

    self.navigationItem.title = headerTitle;
    self.navigationItem.prompt = date;
}

- (void)fetchClocks
{
    NSError *error = nil;
    
	if (![[self fetchedResultsController] performFetch:&error]) 
    {
		NSLog(@"Unresolved error while fetching clocks from DB: %@, %@", error, [error userInfo]);
	}
    else
    {
        m_clocks = [NSMutableArray arrayWithArray:[self fetchedResultsController].fetchedObjects];
        
        if (![Clock dateIsToday:viewDate])
        {
            m_clocks = [self clocksWithMinutes];
        }

        activeClockIndex = NO_ACTIVE_CLOCK;
        int i = 0;

        for (Clock *clock in m_clocks)
        {
            if ([clock isRunning])
            {
                activeClockIndex = i;
                break;
            }
            
            i++;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    activeClockIndex = NO_ACTIVE_CLOCK;
    
    // Set to today.
    viewDate = [NSDate date];
    
    [self setHeader];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dayChartControllerViewDidDisappear) name:NOTIF_DAY_CHART_CONTROLLER_VIEW_DID_DISAPPEAR object:nil];

}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_DAY_CHART_CONTROLLER_VIEW_DID_DISAPPEAR object:nil];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self fetchClocks];
    
    if ([m_clocks count] == 0)
    {
//        [self addClockWithName:@"Clock 1"];
//        [self fetchClocks];
    }
    else
    {
        NSLog(@"Fetched %i clocks.", [m_clocks count]);
    }

    [self.tableView reloadData];

    [self setHeader];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self startTimer];
    
}

- (void)startTimer
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
    [timer invalidate];
    timer = nil;
}

- (NSDate *)dateWithOffset:(NSInteger)daySpan fromDate:(NSDate*)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:daySpan];
    return [gregorian dateByAddingComponents:offsetComponents 
                                      toDate:viewDate 
                                     options:0];
}

- (IBAction)swipedRight:(id)sender 
{
    // Go forward a day.

    viewDate = [self dateWithOffset:-1 fromDate:viewDate];
    [self setHeader];
    
    self.fetchedResultsController = nil;
    [self fetchClocks];
    [self.tableView reloadData];
    
}

- (IBAction)swipedLeft:(id)sender 
{
    if ([Clock dateIsToday:viewDate])
    {
        NSLog(@"Not advancing into future.");
        return;
    }
    
    // Go back a day.
    
    viewDate = [self dateWithOffset:1 fromDate:viewDate];
    [self setHeader];

    self.fetchedResultsController = nil;
    [self fetchClocks];
    [self.tableView reloadData];
    
    
}

- (void)dayChartControllerViewDidDisappear
{
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self stopTimer];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    if ([Clock dateIsToday:viewDate])
    {
        return m_clocks ? [m_clocks count] : 0;
    }
    else
    {
        return [self numberOfClocksWithMinutes];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    if ([Clock dateIsToday:viewDate])
    {
        return m_clocks ? 1 : 0;
    }
    else
    {
        return ([self numberOfClocksWithMinutes] > 0) ? 1 : 0;
    }
}

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return 1;
//}
//
- (void) setCell:(UITableViewCell *)cell active:(BOOL)active clock:(Clock *)clock
{
    NSString *subtitle;
    NSString *minutesFormatted = [Clock minutesFormattedAsTime:[clock minutesOnDate:viewDate] showSeconds:YES];
    

    if (active)
    {
        NSString *entryStartTime = [[clock currentTimeEntry] startTimeFormatted];
        
        subtitle = [NSString stringWithFormat:@"%@ last started at %@", 
                    minutesFormatted, 
                    entryStartTime];
    }
    else
    {
        subtitle = minutesFormatted;
    }

    cell.textLabel.text = clock.name;
    cell.detailTextLabel.text = subtitle;

    // TODO: change background, text color, animate icon, etc    
    cell.backgroundColor = active ? [UIColor whiteColor] : [UIColor clearColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ClockCellId";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Flip a biatch.
    indexPath = [NSIndexPath indexPathForRow:indexPath.section inSection:indexPath.row];
                 
    Clock *clock = (Clock *)[fetchedResultsController objectAtIndexPath:indexPath];
        
    if (clock)
    {
        if ([Clock dateIsToday:viewDate])
        {
            if ([clock isRunning])
            {
                [self setCell:cell active:YES clock:clock];
            }
            else
            {
                [self setCell:cell active:NO clock:clock];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        }
        else
        {
            [self setCell:cell active:NO clock:clock];
            cell.backgroundColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }        
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 96;
}

- (void) turnOffAllClocks
{
    NSInteger i = 0;
    
    for (Clock *clock in m_clocks)
    {
        [clock stop];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:i++ inSection:0];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        [self setCell:cell active:NO clock:clock];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    Clock *clock = [m_clocks objectAtIndex:indexPath.section];
    [self performSegueWithIdentifier:@"ClockDetail" sender:clock];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![Clock dateIsToday:viewDate])
    {
        return;
    }

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    // Get tapped clock.
    Clock *clock = [m_clocks objectAtIndex:indexPath.section];
    
    if ([clock isRunning])
    {
        // Stop
        
        [clock stop];
        activeClockIndex = NO_ACTIVE_CLOCK;
        [self setCell:cell active:NO clock:clock];

        NSString *msg = [NSString stringWithFormat:@"Stopped clock %@ with %.2f minutes", clock.name, clock.minutes];
//        [TestFlight passCheckpoint:msg];
        NSLog(msg, nil);
    }
    else
    {
        // Start
        
        [self turnOffAllClocks];
        [clock start];
        activeClockIndex = indexPath.section;
        [self setCell:cell active:YES clock:clock];

        NSString *msg = [NSString stringWithFormat:@"Started clock %@ with %.2f minutes", clock.name, clock.minutes];
//        [TestFlight passCheckpoint:msg];
        NSLog(msg, nil);
    }

    [_tableView deselectRowAtIndexPath:indexPath animated:YES];    

    [self setHeader];        
}

- (BOOL) aClockIsTicking
{
    return (activeClockIndex != NO_ACTIVE_CLOCK);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddClock"])
    {
        AddClockViewController *c = segue.destinationViewController;
        c.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"ClockDetail"])
    {
        ClockDetailViewController *c = segue.destinationViewController;
        c.clock = sender;
    }
    else if ([segue.identifier isEqualToString:@"DayChart"])
    {
        [self stopTimer];
        DayChartViewController *c = segue.destinationViewController;
        c.clocks = [self clocksWithMinutes];
        c.viewDate = viewDate;
    }
    
}

- (void) tick
{
    [self setHeader];
    
    if ([self aClockIsTicking])
    {
        [self.tableView reloadData];
    }
}


- (void) clockAddingCanceled
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void) addClockWithName:(NSString *)clockName
{
    Clock *clock = (Clock *)[NSEntityDescription insertNewObjectForEntityForName:@"Clock" 
                                                          inManagedObjectContext:managedObjectContext];
	
    clock.name = clockName;
    NSLog(@"New clock: %@", clock);
    [APP_DELEGATE saveContext];
    
//    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Added clock named %@", clockName]];
    
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{    
    if (fetchedResultsController == nil) 
    {
        self.managedObjectContext = APP_DELEGATE.managedObjectContext;
        
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Clock" 
                                                  inManagedObjectContext:managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Sort by name.
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
        
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        self.fetchedResultsController = [[NSFetchedResultsController alloc] 
                                         initWithFetchRequest:fetchRequest 
                                         managedObjectContext:managedObjectContext 
                                         sectionNameKeyPath:nil 
                                         cacheName:@"Root"];
        
        fetchedResultsController.delegate = self;
    }
	
	return fetchedResultsController;
}    


@end
