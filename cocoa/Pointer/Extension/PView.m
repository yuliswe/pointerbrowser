//
//  PView.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PView.h"
@implementation NSView(Pointer)
- (void)addSubviewAndFill:(NSView*)subview
{
    subview.frame = self.bounds;
    subview.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self addSubview:subview];
}
@end

@implementation PView

@end
