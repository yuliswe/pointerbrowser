//
//  AppDelegate.h
//  Pointer
//
//  Created by Yu Li on 2018-07-31.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    NSArray* m_browserWindows;
}

@property NSArray* browserWindows;

- (IBAction)closeTab:(id)sender;

@end

