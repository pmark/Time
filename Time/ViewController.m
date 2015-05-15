
//  ViewController.m
//  Time
//
//  Created by P. Mark Anderson on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"


@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark -

- (void)updateDoc:(CouchDocument *)document
{
    CouchRevision* latest = document.currentRevision;
    NSMutableDictionary* props = [latest.properties mutableCopy];

    int count = [[props objectForKey:@"count"] intValue];
    count++;
    [props setObject: [NSNumber numberWithInt: count] forKey:@"count"];
    
    RESTOperation* op = [latest putProperties: props];
    [op onCompletion: ^{
        if (op.isSuccessful)
            NSLog(@"Successfully updated document!");
        else
            NSLog(@"Failed to update document: %@", op.error);
    }];
}

- (void)listAllDocs
{
//    CouchQuery *allDocs = [db getAllDocuments];
    
//    for (CouchQueryRow *row in allDocs.rows) 
//    {
//        CouchDocument *doc = row.document;
//        NSString *s = [doc.properties objectForKey: @"type"];
//        NSLog(@"Doc %@: %@", row.documentID, s);
//    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

//    if (!server)
//    {
//        dbServerURL = [NSURL URLWithString:@"http://pmark.iriscouch.com/"];
//        server = [[CouchServer alloc] initWithURL:dbServerURL];
//        db = [server databaseNamed:@"time_dev"];
        
//        RESTOperation *op = [db GET];
    
//        if (![op wait]) 
//        {
//            // failed to contact the server or access the database
//            NSLog(@"\n\nCan't connect to remote DB!\n\n");
//        }
//        else
//        {
//            NSLog(@"Fetching docs");
//            [self listAllDocs];
//        }
//        
//    }

}

- (void)viewDidUnload
{
    dayTable = nil;
    settingsPanel = nil;
    intervalMinutesField = nil;
    header = nil;
    panelCloseButton = nil;
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 24;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 84;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TimeIntervalCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    /*
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    */
    
    cell.textLabel.text = @"11:00";
    cell.detailTextLabel.text = @"OMBU";
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)setSettingsPanelHidden:(BOOL)hide
{
    NSInteger direction;
//    CGFloat panelHeight = settingsPanel.frame.size.height + 20;
    CGFloat headerHeight = 40;

    CGPoint tableCenter = dayTable.center;
    CGPoint panelCenter = settingsPanel.center;

    if (hide)
    {
        // Close panel
        direction = -1;
    }
    else
    {
        // Open panel
        direction = 1;
    }

    
    tableCenter.y += direction * 60;    
    panelCenter.y -= direction * headerHeight;
    
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.33];
    
    settingsPanel.center = panelCenter;
    
    dayTable.center = tableCenter;
    dayTable.alpha = (direction == 1) ? 0.10 : 1.0;

    header.alpha = (direction == 1) ? 0.0 : 1.0;

    [UIView commitAnimations];
    
    if (direction == 1)
    {
        [self.view bringSubviewToFront:panelCloseButton];
    }
    else
    {
        [self.view sendSubviewToBack:panelCloseButton];
    }

}

- (void)settingsButtonTapped:(UIButton*)sender 
{
    sender.selected = !sender.selected;

    [self setSettingsPanelHidden:!sender.selected];
}

- (IBAction)panelCloseButtonTapped:(UIButton*)sender 
{
    [self setSettingsPanelHidden:!sender.selected];
}

@end
