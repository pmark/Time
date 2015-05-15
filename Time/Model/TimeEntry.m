//
//  TimeEntry.m
//  Time
//
//  Created by P. Mark Anderson on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimeEntry.h"
#import "Clock.h"
#import "NSDate+Utils.h"

@implementation TimeEntry

@dynamic endTime;
@dynamic startTime;
@dynamic clock;

static NSDate *BaseRefDate = nil;

+ (NSDate *) baseReferenceDate
{
    if (!BaseRefDate)
        BaseRefDate = [NSDate dateWithTimeIntervalSinceReferenceDate:0.0];
    
    return BaseRefDate;
}

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.endTime = [TimeEntry baseReferenceDate];
}

+ (BOOL) isReferenceDate:(NSDate *)date
{
    return [date isEqualToDate:[TimeEntry baseReferenceDate]];
}

- (BOOL) isEnded
{
    return (self.endTime && ![TimeEntry isReferenceDate:self.endTime]);
}

- (BOOL) isStarted
{
    return (self.startTime != nil);
}

- (NSString *)formattedTime:(NSDate *)date
{
    if (!date || [TimeEntry isReferenceDate:date])
        return @"???";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    [dateFormatter setAMSymbol:@"a"];
    [dateFormatter setPMSymbol:@"p"];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString *formatted = [dateFormatter stringFromDate:date];
    return [formatted stringByReplacingOccurrencesOfString:@" " withString:@""];
}    
    
- (NSString *)formattedTimeFromDateComponentsNOT_USED:(NSDate *)date
{    
    NSDateComponents *components = [[NSCalendar currentCalendar] 
                                    components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                    fromDate:date];
    
    NSInteger hour = [components hour];    
    
    NSInteger minute = [components minute];    
    NSString *zero = (minute < 10) ? @"0" : @"";
    NSString *ampm = (hour < 12) ? @"a" : @"p";
    
    hour = (hour > 12) ? hour-12 : hour;
    
    return [NSString stringWithFormat:@"%i:%@%i%@", 
            (hour == 0) ? 12 : hour,
            zero,
            minute,
            ampm];
}

- (NSString *) startTimeFormatted
{
    return [self formattedTime:self.startTime];
}

- (NSString *) endTimeFormatted
{
    return [self formattedTime:self.endTime];
}

// Returns descending if self.endTime is later in time than other time.
- (NSComparisonResult) compare:(TimeEntry *)other
{
    NSComparisonResult r;
    
    if (!self.endTime)
        r = NSOrderedDescending;
    else if (!other.endTime)
        r = NSOrderedAscending;
    else 
        r = [self.endTime compare:other.endTime];
        
    return r;
}

- (CGFloat) minutes
{
    if (!self.startTime)
        return 0.0;
    
    NSDate *endDate;
    
    if ([self isEnded])
        endDate = self.endTime;
    else
        endDate = [NSDate date];
    
    NSTimeInterval seconds = [endDate timeIntervalSinceDate:self.startTime];

    return seconds / 60.0;
}

- (NSString *) report
{
    return [NSString stringWithFormat:@"%@ - %@", 
        self.startTimeFormatted,
        self.endTimeFormatted];
}

@end
