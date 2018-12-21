//
//  PImage.m
//  Pointer
//
//  Created by Yu Li on 2018-12-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "PImage.h"

@implementation NSImage(Pointer)
+ (NSImage*)namedImageWithTintColor:(NSImageName)name color:(NSColor*)color
{
    NSImage* image = [[NSImage imageNamed:name] copy];
    [image lockFocus];
    [color set];
    NSRectFillUsingOperation(NSMakeRect(0, 0, image.size.width, image.size.height), NSCompositingOperationSourceAtop);
    [image unlockFocus];
    [image setTemplate:NO];
    return image;
}
@end
