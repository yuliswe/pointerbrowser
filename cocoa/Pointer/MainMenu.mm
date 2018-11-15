//
//  MainMenu.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "MainMenu.h"
#include <docviewer/docviewer.h>
#import "CppData.h"

@implementation MainMenu

@end

@implementation BookmarkMenuItem
@end

@implementation BookmarkMenuDelegate
- (instancetype)init
{
    self = [super init];
    QObject::connect(&Global::sig, &GlobalSignals::signal_tf_global_objects_initialized, [=]() {
        [self performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:YES];
    });
    return self;
}
- (void)connect
{
    QObject::connect(Global::controller, &Controller::current_tab_webpage_changed, [=]() {
        [self performSelectorOnMainThread:@selector(handleCurrentWebpageChanged) withObject:nil waitUntilDone:YES];
    });
}
- (void)handleCurrentWebpageChanged
{
    self.currentStateNotNull = Global::controller->current_tab_state() != Controller::TabStateNull;
}
- (NSUInteger)bookmarkListOffset
{
    return 6;
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSArray* itemarray = menu.itemArray;
    NSUInteger count = itemarray.count;
    for (NSUInteger i = count - 1; i >= self.bookmarkListOffset; i--) {
        [menu removeItemAtIndex:i];
    }
    int nbooks = Global::controller->bookmarks()->count();
    for (int i = 0; i < nbooks; i++) {
        Webpage_ w = Global::controller->bookmarks()->webpage_(i);
        NSMenuItem* item = [menu insertItemWithTitle:w->title().toNSString() action:@selector(handle_bookmark_clicked:) keyEquivalent:@"" atIndex:i+self.bookmarkListOffset];
        item.target = self;
    }
}

- (void)handle_bookmark_clicked:(NSMenuItem*)item
{
    NSMenu* menu = item.menu;
    int i = [menu indexOfItem:item] - self.bookmarkListOffset;
    Webpage_ w = Global::controller->bookmarks()->webpage_(i);
    Global::controller->currentTabWebpageGoAsync(w->url().full());
}
@end
