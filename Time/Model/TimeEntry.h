//
//  TimeEntry.h
//  Time
//
//  Created by P. Mark Anderson on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Clock;

@interface TimeEntry : NSManagedObject

@property (nonatomic, retain) NSDate *endTime;
@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) Clock *clock;
@property (nonatomic, readonly) CGFloat minutes;

+ (NSDate *) baseReferenceDate;

- (BOOL) isEnded;
- (BOOL) isStarted;
- (NSString *) startTimeFormatted;
- (NSString *) endTimeFormatted;
- (NSString *) report;

@end
