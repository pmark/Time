//
//  ClockDetailViewController.h
//  Time
//
//  Created by P. Mark Anderson on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clock.h"

@interface ClockDetailViewController : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    Clock *m_clock;
    __weak IBOutlet UIButton *m_sunDial;
    __weak IBOutlet UITextField *m_clockNameField;
}

@property (strong) Clock *clock;

- (IBAction)deleteButtonTapped:(id)sender;
- (void) animateSunDial;

@end
