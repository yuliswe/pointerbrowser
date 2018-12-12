//
//  MainMenu.h
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface BookmarksMenuDelegate : NSObject<NSMenuDelegate>
@property BOOL currentStateNotNull;
@end

@interface TagsMenuDelegate : NSObject<NSMenuDelegate>
@property BOOL currentStateNotNull;
@end

@interface FileMenuDelegate : NSObject<NSMenuDelegate>
@property BOOL currentWebpageIsPDF;
@end

NS_ASSUME_NONNULL_END
