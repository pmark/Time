//
//  AddClockViewController.h
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Clock.h"

@protocol AddClockDelegate <NSObject>
- (void) clockAddingCanceled;
- (void) addClockWithName:(NSString *)clockName;
@end

@interface AddClockViewController : UIViewController <UITextFieldDelegate>
{    
    __weak IBOutlet UITextField *m_clockNameField;
    __weak IBOutlet UILabel *m_quotationLabel;
    __weak IBOutlet UILabel *m_quotationSource;
}

@property (weak, nonatomic) IBOutlet id<AddClockDelegate> delegate;

- (IBAction)cancel:(id)sender;
- (void)applyWisdom;

@end
