//
//  ViewController.h
//  Time
//
//  Created by P. Mark Anderson on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CouchCocoa/CouchCocoa.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    __weak IBOutlet UITableView *dayTable;
    
    __weak IBOutlet UIView *settingsPanel;
    __weak IBOutlet UITextField *intervalMinutesField;
    __weak IBOutlet UIView *header;
    __weak IBOutlet UIButton *panelCloseButton;

//    CouchServer *server;
//    CouchDatabase *db;
    NSURL *dbServerURL;
}
- (IBAction)settingsButtonTapped:(id)sender;
- (IBAction)panelCloseButtonTapped:(id)sender;
@end
