//
//  DayChartViewController.h
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DayChartViewController : UIViewController <MFMailComposeViewControllerDelegate>
{    
    IBOutlet UITextView *textView;
    __weak IBOutlet UIImageView *m_chartView;
    __weak IBOutlet UIActivityIndicatorView *m_spinner;
    __weak IBOutlet UILabel *m_chartUnavailableLabel;
    
    __weak IBOutlet UILabel *m_copiedLabel;
    UIPasteboard *pasteboard;
}

@property (strong) NSArray *clocks;
@property (strong) NSDate *viewDate;

- (NSString *)dayReport;
- (IBAction)chartWasTapped:(id)sender;
- (IBAction)emailButtonWasTapped:(id)sender;
- (IBAction)copyButtonWasTapped:(id)sender;


@end

