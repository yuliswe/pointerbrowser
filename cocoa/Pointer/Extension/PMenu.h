//
//  PMenu.h
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMenu(Pointer)
- (void)filterMenuItems;
@end

@interface PMenuDelegate : NSObject<NSMenuDelegate>

@end

@interface PMenu : NSMenu

@end

NS_ASSUME_NONNULL_END
