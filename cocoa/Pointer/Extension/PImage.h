//
//  PImage.h
//  Pointer
//
//  Created by Yu Li on 2018-12-20.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface PImage : NSImage

@end

@interface NSImage(Pointer)
+ (NSImage*)namedImageWithTintColor:(NSString*)image color:(NSColor*)color;
@end

NS_ASSUME_NONNULL_END
