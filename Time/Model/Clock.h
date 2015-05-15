//
//  Clock.h
//  Time
//
//  Created by P. Mark Anderson on 12/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TimeEntry;

@interface Clock : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *totalMinutes;
@property (nonatomic, retain) NSSet *timeEntries;
@property (nonatomic, assign) CGFloat minutes;

- (BOOL) toggle;
- (void) stop;
- (void) start;
- (BOOL) isRunning;
- (TimeEntry *) currentTimeEntry;
- (NSString *) totalTimeFormatted;
- (NSString *) totalTimeFormattedOnDate:(NSDate*)date;
//- (NSArray *) timeEntriesTodaySorted;
- (NSArray *) timeEntriesSortedOnDate:(NSDate*)date;
- (NSString *) timeEntriesTodayFormatted;
- (NSString *) timeEntriesFormattedOnDate:(NSDate*)date;
- (NSString *) timeEntriesFormattedOnDate:(NSDate*)date delimiter:(NSString *)delimiter;
- (NSSet *) timeEntriesToday;
- (BOOL) hasTimeEntriesToday;
- (CGFloat) minutesToday;
- (CGFloat) minutesOnDate:(NSDate*)date;

+ (BOOL) dateIsToday:(NSDate *)date;
+ (NSString *) minutesFormattedAsTime:(CGFloat)totalMinutes showSeconds:(BOOL)withSeconds;
+ (NSDate *) convertToGMT:(NSDate *)sourceDate;
+ (NSDate *) GMTNow;
+ (NSString *) GMTDateString:(NSDate *)date;
+ (NSDate *) convertToUTC:(NSDate *)sourceDate;
+ (NSString *) currentLocalTime;
+ (NSString *) getUTCFormatDate:(NSDate *)localDate;
+ (NSString *) formattedDate:(NSDate *)date;
+ (NSString *) formattedDayOfMonth:(NSInteger)day;

@end


@interface Clock (CoreDataGeneratedAccessors)

- (void)addTimeEntriesObject:(TimeEntry *)value;
- (void)removeTimeEntriesObject:(TimeEntry *)value;
- (void)addTimeEntries:(NSSet *)values;
- (void)removeTimeEntries:(NSSet *)values;
@end
