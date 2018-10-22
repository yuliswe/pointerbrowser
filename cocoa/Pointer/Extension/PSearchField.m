//
//  PSearchField.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PSearchField.h"

@implementation PSearchField

- (void)mouseDown:(NSEvent *)event
{
    // do nothing
}


- (void)willOpenMenu:(NSMenu *)menu
           withEvent:(NSEvent *)event
{
    NSArray* itemarray = menu.itemArray;
    for (int i = itemarray.count - 1; i >= 0; i--) {
        NSMenuItem* item = itemarray[i];
        if (! [item.title containsString:@"Copy"]
            && ! [item.title containsString:@"Cut"]
            && ! [item.title containsString:@"Paste"]
            && ! [item.title containsString:@"Look Up"])
        {
            [menu removeItem:item];
        }
    }
}

@end
