//
//  PTextView.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PTextView.h"
#import "PMenu.h"
#import "../KeyCode.h"

@implementation PTextView

- (instancetype)init
{
    self = [super init];
    self.fieldEditor = YES;
    return self;
}

- (instancetype)initWithNSText:(NSText*)text
{
    self = (PTextView*)text;
    self.fieldEditor = YES;
    return self;
}

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
//- (void)keyUp:(NSEvent *)event
//{
//    if (event.keyCode == kVK_Return) {
//        [self complete:self];
//    } else {
//        [super keyUp:event];
//    }
//}
//
//- (NSMenu *)menuForEvent:(NSEvent *)event
//{
//    return [[NSMenu alloc] init];
//}

@end
