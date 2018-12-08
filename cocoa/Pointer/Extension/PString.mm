//
//  PAttributedString.m
//  Pointer
//
//  Created by Yu Li on 2018-12-08.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PString.h"

@implementation NSMutableAttributedString (Pointer)
- (void)highlight:(RangeSet const&)ranges
{
    for (auto i = ranges.begin(); i != ranges.end(); i++) {
        NSUInteger start = i->first;
        NSUInteger len = i->second;
        [self addAttributes:@{NSForegroundColorAttributeName:NSColor.systemPinkColor} range:NSMakeRange(start, len)];
    }
}
@end
