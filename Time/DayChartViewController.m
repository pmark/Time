//
//  DayChartViewController.m
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DayChartViewController.h"
#import "Clock.h"
#import "UIImageView+AFNetworking.h"
#import "Constants.h"
#import "AFHTTPClient.h"
#import <QuartzCore/QuartzCore.h>

@implementation DayChartViewController

@synthesize clocks;
@synthesize viewDate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_DAY_CHART_CONTROLLER_VIEW_DID_DISAPPEAR
                                                        object:nil];
}

- (void) fetchChart
{
    // Gather chart data from all clocks, get total minutes on this day.
    
    NSMutableArray *clockNames = [NSMutableArray array];
    NSMutableArray *clockMinutes = [NSMutableArray array];
    
    for (Clock *clock in self.clocks)
    {
        [clockNames addObject:clock.name];
        [clockMinutes addObject:[NSString stringWithFormat:@"%.1f", [clock minutesToday]]];
    }
    
    NSString *nameList = [clockNames componentsJoinedByString:@"|"];
    NSString *minuteList = [clockMinutes componentsJoinedByString:@","];    
    
    NSString *urlString = [NSString stringWithFormat:
                           @"http://chart.apis.google.com/chart?chs=300x150&cht=p3&chf=bg,s,FFFFFF00&chd=t:%@&chdl=%@", 
                           minuteList, 
                           AFURLEncodedStringFromStringWithEncoding(nameList, NSUTF8StringEncoding)];
    
    NSLog(@"Requesting chart:\n\n%@\n\n", urlString);
    NSURL *url = [NSURL URLWithString:urlString];

    [m_chartView setImageWithURLRequest:[NSURLRequest requestWithURL:url] 
                       placeholderImage:nil 
                                success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         [m_spinner stopAnimating];
         
     }
                                failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)
     {
         [m_spinner stopAnimating];
         m_chartUnavailableLabel.hidden = NO;
         
     }];
    
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"ChartScreenBackground_320x480.png"]];
    
    textView.text = [self dayReport];
    
    CALayer *l = [textView layer];
    [l setBorderWidth:1];
    [l setBorderColor:[UIColor colorWithWhite:0.6 alpha:1.0].CGColor];
    [l setCornerRadius:12];
    [l setMasksToBounds:YES];
    textView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.2];
    
    [self fetchChart];
    
    pasteboard = [UIPasteboard generalPasteboard];
    
//    [TestFlight passCheckpoint:@"Viewed day report"];

}

- (void)viewDidUnload
{
    textView = nil;
    m_spinner = nil;
    m_chartView = nil;
    m_chartUnavailableLabel = nil;
    m_copiedLabel = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)dayReport
{
    static NSString *format = @"* %@ (%@)\n%@\n\n";
    NSMutableString *report = [NSMutableString string];
//    NSMutableString *line;
    
    for (Clock *clock in self.clocks)
    {
        NSString *formattedTime = [clock totalTimeFormattedOnDate:self.viewDate];
        
//        int lineLength = [clock.name length] + [formattedTime length] + 3;
//        line = [NSMutableString stringWithCapacity:lineLength];
        
//        for (int i=0; i < lineLength; i++)
//        {
//            // Draw underline made of hyphens.
//            [line appendString:@"-"];
//        }
                           
        [report appendFormat:format, 
         [clock name], 
         formattedTime, 
//         line,
         [clock timeEntriesFormattedOnDate:viewDate]];
    }
    
    return report;
}

- (IBAction)chartWasTapped:(id)sender 
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)emailButtonWasTapped:(id)sender 
{
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;

    [mailer setSubject:[NSString stringWithFormat:@"%Time for %@", 
                        [Clock formattedDate:self.viewDate]]];

    [mailer setMessageBody:[self dayReport] isHTML:NO];

//    [TestFlight passCheckpoint:@"Day report email button tapped"];
    
    [self presentModalViewController:mailer animated:YES];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self dismissModalViewControllerAnimated:YES];
}

- (void)hideCopiedLabel
{
    m_copiedLabel.hidden = YES;
}

- (IBAction)copyButtonWasTapped:(id)sender 
{
    pasteboard.string = textView.text;

    m_copiedLabel.hidden = NO;
    [self performSelector:@selector(hideCopiedLabel) withObject:nil afterDelay:1.5];
    
//    [TestFlight passCheckpoint:@"Copied day report"];

}

@end
