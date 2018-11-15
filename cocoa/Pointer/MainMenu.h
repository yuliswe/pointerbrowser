//
//  MainMenu.h
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MainMenu : NSObject
@end

@interface BookmarkMenuItem : NSMenuItem
@end

@interface BookmarkMenuDelegate : NSObject<NSMenuDelegate>
@property BOOL currentStateNotNull;
@end

NS_ASSUME_NONNULL_END
