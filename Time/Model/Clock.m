//
//  Clock.m
//  Time
//
//  Created by P. Mark Anderson on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Clock.h"
#import "TimeEntry.h"
#import "AppDelegate.h"
#import "NSDate+Utils.h"


@implementation Clock

@dynamic name;
@dynamic totalMinutes;
@dynamic timeEntries;
@synthesize minutes;

- (void) awakeFromFetch
{
    [super awakeFromFetch];
    self.minutes = 0.0;
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.minutes = 0.0;
}

- (TimeEntry *) currentTimeEntry
{
    for (TimeEntry *entry in self.timeEntries)
    {
        if (![entry isEnded])
            return entry;
    }
    
    return nil;
}

- (CGFloat) uncountedMinutes
{
    TimeEntry *current = [self currentTimeEntry];
    
    if (current && [current isStarted])
        return [current.startTime timeIntervalSinceNow] / -60.0;
    else
        return 0.0;
}

- (void) stop
{
    if (![self isRunning])
    {
        NSLog(@"NOTICE: Won't stop clock that is already stopped.");
        return;
    }
    
    TimeEntry *current = [self currentTimeEntry];
    
    if (current && [current isStarted])
    {
        CGFloat extra = [self uncountedMinutes];
        minutes = minutes + extra;  // CAUTION: don't use setter        
        current.endTime = [NSDate date];
    }
    
    [APP_DELEGATE saveContext];
    
    NSLog(@"Canceling local notification.");
    [[UIApplication sharedApplication] cancelAllLocalNotifications];    
}

- (void) start
{
    if ([self isRunning])
    {
        NSLog(@"NOTICE: Won't start clock that is already running.");
        return;
    }
    
    TimeEntry *entry = (TimeEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"TimeEntry" 
                                                                  inManagedObjectContext:APP_DELEGATE.managedObjectContext];
	
    entry.startTime = [[NSDate date] toLocalTime];

    entry.startTime = [NSDate date];  // 8 hours later than local time  

    NSLog(@"Starting clock at %@", entry.startTime);
    
    [self addTimeEntriesObject:entry];
    [APP_DELEGATE saveContext];
    
    NSDate *alertTime = [NSDate dateWithTimeIntervalSinceNow:30*60];

    [APP_DELEGATE addNotificationAt:alertTime 
                          alertBody:@"What are you up to?" 
                          soundName:@"crow.wav" 
                              badge:1
                           userInfo:nil];
}

/*
 * @return true if clock becomes active.
 *
 */
- (BOOL) toggle
{
    BOOL active;
    TimeEntry *current = [self currentTimeEntry];
    
    if (current && [current isStarted])
    {
        [self stop];
        active = NO;        
    }
    else
    {
        [self start];
        active = YES;
    }
    
    return active;
}

- (CGFloat) minutes
{
    return minutes + [self uncountedMinutes];
}

- (BOOL) isRunning
{
    BOOL running = NO;

    TimeEntry *current = [self currentTimeEntry];

    if (current)
    {
        running = [current isStarted] && ![current isEnded];
//        NSLog(@"Is running? %@,  TE: %@", running?@"Y":@"N", [current report]);
//        NSLog(@"Is Started? %@", [current isStarted]?@"Y":@"N");
//        NSLog(@"Is Ended? %@", [current isEnded]?@"Y":@"N");
    }
    else
    {
//        NSLog(@"\n!!!!!!!There's no current entry for this clock!");
    }
    
    return running;
}

- (NSString *) totalTimeFormatted
{
    return [Clock minutesFormattedAsTime:[self minutesToday] showSeconds:NO];
}

- (NSString *) totalTimeFormattedOnDate:(NSDate*)date
{
    return [Clock minutesFormattedAsTime:[self minutesOnDate:date] showSeconds:NO];
}

- (NSString *) timeEntriesFormattedOnDate:(NSDate*)date delimiter:(NSString *)delimiter
{
    if (!delimiter)
        delimiter = @", ";
    
    NSMutableString *report = [NSMutableString string];
    
    BOOL first = YES;
    
    for (TimeEntry *timeEntry in [self timeEntriesSortedOnDate:date])
    {
        if (first)
            first = NO;
        else
            [report appendString:delimiter];
        
        [report appendString:[timeEntry report]];
    }
    
    return report;
}

- (NSString *) timeEntriesFormattedOnDate:(NSDate*)date
{
    return [self timeEntriesFormattedOnDate:date delimiter:nil];
}

- (NSString *) timeEntriesTodayFormatted
{
    return [self timeEntriesFormattedOnDate:[NSDate date] delimiter:nil];
}

#pragma Utility

+ (NSString *) minutesFormattedAsTime:(CGFloat)totalMinutes showSeconds:(BOOL)withSeconds
{
    NSInteger hours = (totalMinutes/60);
    NSInteger minutes = ((int)totalMinutes%60);
    NSString *zero = (minutes < 10) ? @"0" : @"";
    NSString *time = [NSString stringWithFormat:@"%i:%@%i", hours, zero, minutes];
    
    if (withSeconds)
    {
        CGFloat fraction = (totalMinutes - (int)totalMinutes);
        NSInteger seconds = fraction * 60;
        zero = (seconds < 10) ? @"0" : @"";
        time = [time stringByAppendingFormat:@":%@%i", zero, seconds];
    }
    
    return time;
}

- (BOOL) hasTimeEntriesToday
{
    // TODO: Optimize this?
    return ([[self timeEntriesToday] count] > 0);
}

#pragma mark -

+ (BOOL) dateIsToday:(NSDate *)date
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:date];
    NSDateComponents *otherDateComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];

    return ([todayComponents day] == [otherDateComponents day] &&
            [todayComponents month] == [otherDateComponents month] &&
            [todayComponents year] == [otherDateComponents year]);
}

+ (NSPredicate *) predicateForEntriesWithinDateRangeFrom:(NSDate *)startOfRange daySpan:(NSInteger)daySpan
{
    // Start by retrieving day, weekday, month and year components for today.
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *startDayComponent = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:startOfRange];
    NSInteger theDay = [startDayComponent day];
    NSInteger theMonth = [startDayComponent month];
    NSInteger theYear = [startDayComponent year];
    
    
    // Now build a NSDate object for the input date using these components.
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay]; 
    [components setMonth:theMonth]; 
    [components setYear:theYear];
    NSDate *startDate = [gregorian dateFromComponents:components];
    
    
    // Now build a NSDate object for tomorrow.
    
    if (daySpan < 1)
        daySpan = 1;
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:daySpan];
    NSDate *nextDate = [gregorian dateByAddingComponents:offsetComponents 
                                                  toDate:startDate 
                                                 options:0];
    
    //    NSDateComponents *tomorrowComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:nextDate];
    
    //    NSInteger tomorrowDay = [tomorrowComponents day];
    //    NSInteger tomorrowMonth = [tomorrowComponents month];
    //    NSInteger tomorrowYear = [tomorrowComponents year];
    
    // Now build the predicate needed to fetch the information.
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
              @"(startTime < %@ && startTime > %@) && (endTime == %@ || (endTime < %@ && endTime > %@))", 
                              nextDate, 
                              startDate,
                              [TimeEntry baseReferenceDate],
                              nextDate,
                              startDate];
    
    return predicate;
}

+ (NSPredicate *) predicateForToday
{
    return [self predicateForEntriesWithinDateRangeFrom:[NSDate date] daySpan:1];
}

+ (NSPredicate *) predicateForDate:(NSDate*)date
{
    return [self predicateForEntriesWithinDateRangeFrom:date daySpan:1];
}

- (NSSet *) timeEntriesOnDate:(NSDate*)date
{
    NSSet *set = nil;
    
    @try {
        set = [self.timeEntries filteredSetUsingPredicate:[Clock predicateForDate:date]];
    }
    @catch (NSException *exception) {
        NSLog(@"Couldn't get clock's entries. %@", [exception description]);
    }
    
    return set;
}

- (NSSet *) timeEntriesToday
{
    NSSet *set = nil;
    
    @try {
        set = [self.timeEntries filteredSetUsingPredicate:[Clock predicateForToday]];
    }
    @catch (NSException *exception) {
        NSLog(@"Couldn't get clock's entries. %@", [exception description]);
    }

    return set;
}

- (NSArray *) timeEntriesSortedOnDate:(NSDate*)date
{
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
                                initWithKey:@"startTime"
                                ascending:YES];
    
    NSArray *sorts = [NSArray arrayWithObject:sorter];

    NSSet *set = [self timeEntriesOnDate:date];

    NSArray *sorted = nil;
    
    if (set)
    {
        sorted = [set sortedArrayUsingDescriptors:sorts];
    }
    
    return sorted;
}

//- (NSArray *) timeEntriesTodaySorted
//{    
//}
- (CGFloat) minutesOnDate:(NSDate*)date
{
    CGFloat sum = 0.0;
    NSSet *entries = [self timeEntriesOnDate:date];
    
    //    int i=0;
    for (TimeEntry *timeEntry in entries)
    {
        //        NSLog(@"%@: Entry %i started this many minutes ago %f and has this many minutes clocked: %f", 
        //              self.name,
        //              i++,
        //              [timeEntry.startTime timeIntervalSinceNow]/60.0, 
        //              timeEntry.minutes);
        
        sum += timeEntry.minutes;
    }
    
    return sum;
}


- (CGFloat) minutesToday
{
    CGFloat sum = 0.0;
    NSSet *entries = [self timeEntriesToday];
    
//    int i=0;
    for (TimeEntry *timeEntry in entries)
    {
//        NSLog(@"%@: Entry %i started this many minutes ago %f and has this many minutes clocked: %f", 
//              self.name,
//              i++,
//              [timeEntry.startTime timeIntervalSinceNow]/60.0, 
//              timeEntry.minutes);
        
        sum += timeEntry.minutes;
    }
    
    return sum;
}

#pragma mark -

+ (NSDate *) convertToUTC:(NSDate *)sourceDate
{
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMTForDate:sourceDate];
    NSInteger gmtOffset = [utcTimeZone secondsFromGMTForDate:sourceDate];
    NSTimeInterval gmtInterval = gmtOffset - currentGMTOffset;

    return [NSDate dateWithTimeInterval:-gmtInterval sinceDate:sourceDate];	
}

+ (NSString *) GMTDateString:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    
    // Set date style:
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *) GMTNow
{ 
    NSDate *sourceDate = [NSDate date];
    NSTimeZone* currentTimeZone = [NSTimeZone localTimeZone];
    NSInteger currentGMTOffset = [currentTimeZone secondsFromGMT];
    
    return [sourceDate dateByAddingTimeInterval:currentGMTOffset];
}

+ (NSDate *) convertToGMT:(NSDate *)sourceDate
{
    NSTimeZone *currentTimeZone = [NSTimeZone localTimeZone];
    NSTimeInterval gmtInterval = [currentTimeZone secondsFromGMTForDate:sourceDate];
    return [NSDate dateWithTimeInterval:gmtInterval sinceDate:sourceDate];     
}

+ (NSString *) getUTCFormatDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"HH:mma"];
    return [dateFormatter stringFromDate:localDate];
}

+ (NSString *) currentLocalTime
{
    return [Clock getUTCFormatDate:[NSDate date]];
}

+ (NSArray *) startTimeSortDescriptor
{
    NSSortDescriptor *sorter = [[NSSortDescriptor alloc]
               initWithKey:@"startTime"
               ascending:YES];
    
    return ([NSArray arrayWithObject:sorter]);
    
}


+ (NSString *)formattedDayOfMonth:(NSInteger)day
{
    NSString *s;
    
    switch (day) 
    {
        case 1:
        case 21:
        case 31:
            s = @"st";
            break;
            
        case 2:
        case 22:
            s = @"nd";
            break;
            
        case 3:
        case 23:
            s = @"rd";
            break;
            
        default:
            s = @"th";
            break;
    }
    
    return [NSString stringWithFormat:@"%i%@", day, s];
}

+ (NSString *)formattedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];    
    
    NSDateComponents *components = [[NSCalendar currentCalendar] 
                                    components:NSDayCalendarUnit  // | NSMonthCalendarUnit | NSYearCalendarUnit 
                                    fromDate:date];
    
    NSInteger day = [components day];    
    
    // Sun
    [dateFormatter setDateFormat:@"E"];
    NSMutableString *s = [NSMutableString stringWithString:[dateFormatter stringFromDate:date]];
    
    // Sun 4th
    [s appendFormat:@" %@ ", [Clock formattedDayOfMonth:day]];
    
    // Sun 4th Dec 2010
    [dateFormatter setDateFormat:@"MMM YYYY"];    
    [s appendString:[dateFormatter stringFromDate:date]];
    
    return s;
}

@end
