//
//  AddClockViewController.m
//  Time
//
//  Created by P. Mark Anderson on 12/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddClockViewController.h"

@implementation AddClockViewController

@synthesize delegate;

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

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

#define TICKTOCK1 @"Tick tock"
#define TICKTOCK2 @"You don't stop"

- (void)ticktock
{
    m_clockNameField.placeholder = [m_clockNameField.placeholder isEqualToString:TICKTOCK1] ? TICKTOCK2 : TICKTOCK1;
    [self performSelector:@selector(ticktock) withObject:nil afterDelay:1.66];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [m_clockNameField becomeFirstResponder];
    [self applyWisdom];
    
    m_clockNameField.placeholder = TICKTOCK2;
    [self ticktock];
}

- (void)viewDidUnload
{
    m_clockNameField = nil;
    m_quotationLabel = nil;
    m_quotationSource = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

/*
- (void)createClock:(NSString*)name
{
    NSManagedObjectContext *context = event.managedObjectContext;
    
	// If the event already has a photo, delete it.
	if (event.photo) {
		[context deleteObject:event.photo];
	}
	
	// Create a new photo object and set the image.
	Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];

}
*/

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"New clock name: %@", textField.text);
    [delegate addClockWithName:textField.text];
    
    return YES;
}

- (IBAction)cancel:(id)sender 
{
    [delegate clockAddingCanceled];
}

- (void)applyWisdom
{
    NSArray *quotations = [NSArray arrayWithObjects:
                           @"An unhurried sense of time is in itself a form of wealth.",
                           @"Bonnie Friedman",
                           @"Time is the coin of your life. It is the only coin you have, and only you can determine how it will be spent. Be careful lest you let other people spend it for you.", 
                           @"Carl Sandburg (1878 - 1967)",
                           @"Time is an illusion. Lunchtime doubly so.", 
                           @"Douglas Adams (1952 - 2001)",
                           @"Nothing is as far away as one minute ago.", 
                           @"Jim Bishop",
                           @"We must use time as a tool, not as a crutch.", 
                           @"John F. Kennedy (1917 - 1963)",
                           @"If we take care of the moments, the years will take care of themselves.", 
                           @"Maria Edgeworth",
                           @"Regret for wasted time is more wasted time.", 
                           @"Mason Cooley",
                           @"What may be done at any time will be done at no time.", 
                           @"Scottish Proverb",
                           nil];
    
    NSInteger quotationCount = [quotations count];
    NSInteger i = (arc4random() % (quotationCount / 2)) * 2;
    NSString *quotation = [quotations objectAtIndex:i];
    NSString *source = [quotations objectAtIndex:i+1];
    
    CGRect sourceFrame = m_quotationSource.frame;
    CGRect quotationFrame = m_quotationLabel.frame;
    quotationFrame.size.height = 120;

    CGSize textSize = [quotation sizeWithFont:m_quotationLabel.font
                            constrainedToSize:quotationFrame.size 
                                lineBreakMode:m_quotationLabel.lineBreakMode];

    NSLog(@"height: %.0f", textSize.height);

    quotationFrame.origin.y = (170 - textSize.height - sourceFrame.size.height) / 2 + 75;
    quotationFrame.size.height = textSize.height;
    m_quotationLabel.frame = quotationFrame;
    m_quotationLabel.text = quotation;    
    
    sourceFrame.origin.y = quotationFrame.origin.y + quotationFrame.size.height + 12;
    m_quotationSource.frame = sourceFrame;
    m_quotationSource.text = source;
}

@end
