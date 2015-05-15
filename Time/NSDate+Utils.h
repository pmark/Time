//
//  NSDate+Utils.h
//  Time
//
//  Created by P. Mark Anderson on 12/31/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Utils)

- (NSDate *) toLocalTime;
- (NSDate *) toGlobalTime;

@end
