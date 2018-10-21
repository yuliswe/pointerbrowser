//
//  AppDelegate.m
//  Pointer
//
//  Created by Yu Li on 2018-07-31.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "Application.mm.h"
#import "BrowserWindow.mm.h"
#include <docviewer/global.hpp>
#include <QtCore/QStringList>
#include <QtCore/QString>

@implementation AppDelegate

@synthesize browserWindows = m_browserWindows;

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    QStringList argv;
    int argc = static_cast<int>([args count]);
    for (int i = 0; i < argc; i++) {
        argv << QString::fromNSString(args[i]);
    }
    Global::startQCoreApplicationThread(argc, argv);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.browserWindows = [[NSArray alloc] initWithObjects:[[BrowserWindowController alloc] init], nil];
    // Insert code here to initialize your application
    size_t s = [self.browserWindows count];
    for (size_t i = 0; i < s; i++) {
        [self.browserWindows[i] showWindow:self];
    }
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    Global::stopQCoreApplicationThread();
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

- (IBAction)closeTab:(id)sender
{
    Global::controller->closeTabAsync();
}

- (IBAction)showFindTextOnPage:(id)sender
{
    Global::controller->currentTabWebpageFindTextShowAsync();
}

@end
