//
//  ClockDetailViewController.m
//  Time
//
//  Created by P. Mark Anderson on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClockDetailViewController.h"
#import "AppDelegate.h"

@implementation ClockDetailViewController

@synthesize clock = m_clock;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    m_clockNameField.text = m_clock.name;
}

- (void)viewDidUnload
{
    m_sunDial = nil;
    m_clockNameField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self animateSunDial];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) 
    {
        case 0:
            return 2;
            break;
            
        case 1:
            return 3;
            break;
            
        default:
            return 1;
            break;
    }
}
*/
#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
}

- (IBAction) deleteButtonTapped:(id)sender 
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete Clock" message:@"Are you sure?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];    
    
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        // Delete this clock.
        
        [APP_DELEGATE.managedObjectContext deleteObject:m_clock];    
        [APP_DELEGATE saveContext];
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) animateSunDial
{
    NSLog(@"sun dial alpha: %f", m_sunDial.alpha);
    CGRect f = m_sunDial.frame;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:12];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:INFINITY];
    
    f.size.width *= 0.66;
    m_sunDial.alpha *= 0.15;
    m_sunDial.frame = f;
    
    [UIView commitAnimations];
}

#pragma mark -

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    NSLog(@"should end editing");
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"did end editing");
}


- (void)saveClock
{
    [APP_DELEGATE saveContext];
    
//    NSManagedObjectContext *context = m_clock.managedObjectContext;
    
/*
    if (clock.image) 
    {
        [context deleteObject:clock.image];
    }
    
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
*/
    
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"Set clock name: %@", textField.text);
    NSString *oldClockName = m_clock.name;
    m_clock.name = textField.text;
    [textField resignFirstResponder];
    
    [self saveClock];

    if (![oldClockName isEqualToString:m_clock.name])
    {
//        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Renamed clock from %@ to %@", oldClockName, m_clock.name]];
    }
    
    return YES;
}

@end
