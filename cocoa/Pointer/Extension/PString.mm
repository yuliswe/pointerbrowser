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
    [self highlightWithColor:ranges highlight:NSColor.systemPinkColor];
}

- (void)highlightWithColor:(RangeSet const&)ranges highlight:(NSColor*)highlight
{
    for (auto i = ranges.begin(); i != ranges.end(); i++) {
        NSUInteger start = i->first;
        NSUInteger len = i->second;
        [self addAttributes:@{NSForegroundColorAttributeName:highlight} range:NSMakeRange(start, len)];
    }
}

- (void)highlightWithColor:(RangeSet const&)ranges normal:(NSColor*)normal highlight:(NSColor*)highlight
{
    [self addAttributes:@{NSForegroundColorAttributeName:normal} range:NSMakeRange(0, self.length)];
    [self highlightWithColor:ranges highlight:highlight];
}
@end
