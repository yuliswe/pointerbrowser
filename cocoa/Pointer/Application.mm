//
//  AppDelegate.m
//  Pointer
//
//  Created by Yu Li on 2018-07-31.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "Application.mm.h"
#import "BrowserWindow.mm.h"
#include <docviewer/docviewer.h>

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.browserWindowController = [[BrowserWindowController alloc] init];
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    QStringList argv;
    int argc = static_cast<int>([args count]);
    for (int i = 0; i < argc; i++) {
        argv << QString::fromNSString(args[i]);
    }
    QObject::connect(&Global::sig, &GlobalSignals::signal_tf_everything_loaded, [=]() {
        NSArray* urls = [[NSFileManager defaultManager] URLsForDirectory:NSDownloadsDirectory inDomains:NSUserDomainMask];
        NSURL* downloads_url = urls[0];
        Global::controller->set_downloads_dirpath_direct(QString::fromNSString(downloads_url.path));
        [self.browserWindowController performSelectorOnMainThread:@selector(showWindow:) withObject:self waitUntilDone:YES];
    });
    Global::startQCoreApplicationThread(argc, argv);
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
