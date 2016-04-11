/*
 Muscle Book
 Copyright (C) 2016  Cristian Filipov

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#import "NSDate+Fast.h"
#import "CBLParseDate.h"

@implementation NSDate (Fast)

+ (NSDate *)parseISO8601Date:(NSString *)string {
    static NSTimeInterval k1970ToReferenceDate;
    static dispatch_once_t onceToken;
    
    dispatch_once (&onceToken, ^{
        k1970ToReferenceDate = [[NSDate dateWithTimeIntervalSince1970: 0.0]
                                timeIntervalSinceReferenceDate];
    });
    
    NSTimeInterval t = CBLParseISO8601Date(string.UTF8String) + k1970ToReferenceDate;
    return [NSDate dateWithTimeIntervalSinceReferenceDate: t];
}

// https://blog.soff.es/how-to-drastically-improve-your-app-with-an-afternoon-and-instruments
- (NSString *)ISO8601String {
    struct tm *timeinfo;
    char buffer[80];

    time_t rawtime = [self timeIntervalSince1970] - [[NSTimeZone localTimeZone] secondsFromGMT];
    timeinfo = localtime(&rawtime);

    strftime(buffer, 80, "%Y-%m-%dT%H:%M:%S%z", timeinfo);

    return [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
}

@end
