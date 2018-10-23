//
//  MainMenu.m
//  Pointer
//
//  Created by Yu Li on 2018-10-22.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "MainMenu.h"
#include <docviewer/docviewer.h>
#import "CppData.mm.h"

@implementation MainMenu

@end

@implementation BookmarkMenuItem
@end

@implementation BookmarkMenuDelegate
- (void)menuNeedsUpdate:(NSMenu *)menu
{
    int offset = 3;
    NSArray* itemarray = menu.itemArray;
    NSUInteger count = itemarray.count;
    for (NSUInteger i = count - 1; i >= offset; i--) {
        [menu removeItemAtIndex:i];
    }
    int nbooks = Global::controller->bookmarks()->count();
    for (int i = 0; i < nbooks; i++) {
        Webpage_ w = Global::controller->bookmarks()->webpage_(i);
        NSMenuItem* item = [menu insertItemWithTitle:w->title().toNSString() action:@selector(handle_bookmark_clicked:) keyEquivalent:@"" atIndex:i+offset];
        item.target = self;
    }
}

- (void)handle_bookmark_clicked:(NSMenuItem*)item
{
    int offset = 3;
    NSMenu* menu = item.menu;
    int i = [menu indexOfItem:item] - offset;
    Webpage_ w = Global::controller->bookmarks()->webpage_(i);
    Global::controller->currentTabWebpageGoAsync(w->url().full());
}
@end
