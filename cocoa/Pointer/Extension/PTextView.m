//
//  PTextView.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PTextView.h"
#import "PMenu.h"

@implementation PTextView

- (void)willOpenMenu:(NSMenu *)menu
           withEvent:(NSEvent *)event
{
    [menu filterMenuItems];
}

- (id)validRequestorForSendType:(NSPasteboardType)sendType
                     returnType:(NSPasteboardType)returnType
{
    return nil;
}
//
//- (NSMenu *)menuForEvent:(NSEvent *)event
//{
//    return [[NSMenu alloc] init];
//}

@end
