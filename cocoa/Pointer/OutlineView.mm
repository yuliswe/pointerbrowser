//
//  OutlineView.m
//  Pointer
//
//  Created by Yu Li on 2018-08-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "OutlineView.mm.h"
#import "CppData.h"
#include <docviewer/webpage.hpp>
#include <docviewer/global.hpp>
#include <Carbon/Carbon.h>

@implementation TrackingAreaCellView
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.hovered = NO;
    self.tracking_area = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow|NSTrackingMouseMoved owner:self userInfo:nil];
    [self addTrackingArea:self.tracking_area];
    return self;
}

- (void)mouseEntered:(NSEvent *)event
{
    self.hovered = YES;
    [super mouseEntered:event];
}

- (void)mouseMoved:(NSEvent *)event
{
    self.hovered = YES;
    [super mouseMoved:event];
}

- (void)mouseExited:(NSEvent *)event
{
    self.hovered = NO;
    [super mouseExited:event];
}
- (IBAction)closeTab:(id)sender
{
    NSInteger index = [self.outlineView childIndexForItem:self.item];
    Global::controller->closeTabAsync(Controller::TabStateOpen, static_cast<int>(index));
}
@end

@implementation WorkspaceHeaderCellUnpinButton
- (void)mouseDown:(NSEvent*)event
{
    [super mouseDown:event];
    [self.headerCellView unpin:self];
}
@end

@implementation WorkspaceHeaderCellView
- (IBAction)unpin:(id)sender
{
    WorkspaceGroupItem* item = self.item;
    TagContainer_ container = item.tagContainer;
    int idx = [self.outlineView childIndexForItem:item];
    Global::controller->workspacesRemoveTagContainerAsync(idx - self.outlineView.workspacesOffset);
}
@end

@implementation OpenTabItem
- (instancetype)initWithWebpage:(Webpage_)w outlineView:(OutlineView*)outlineView
{
    self = [super init];
    self.webpage = w;
    w->set_associated_frontend_tab_object_unsafe((__bridge void*)self);
    self.title = w->title().toNSString();
    self.outlineView = outlineView;
    QObject::connect(w.get(), &Webpage::propertyChanged, [=]() {
        [outlineView performSelectorOnMainThread:@selector(handleDataChanged:) withObject:self waitUntilDone:YES];
    });
    return self;
}
- (IBAction)closeTab
{
    NSInteger index = [self.outlineView childIndexForItem:self];
    Global::controller->closeTabAsync(Controller::TabStateOpen, static_cast<int>(index));
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    int index = [propertyList intValue];
    Webpage_ w = Global::controller->open_tabs()->webpage_(index);
    return [self initWithWebpage:w outlineView:nil];
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    if ([type isEqualToString:@"com.pointerbrowser.pasteboarditem.tab.open"]) {
        int index = Global::controller->open_tabs()->findTab(self.webpage);
        return [NSNumber numberWithInt:index];
    }
    return nil;
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.open"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.open"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end

@implementation OpenGroupItem
- (instancetype)init
{
    self = [super init];
    self.children = [[NSMutableArray alloc] init];
    return self;
}
@end

@implementation SearchResultTabItem
- (instancetype)initWithWebpage:(Webpage_)w outlineView:(OutlineView*)outlineView
{
    self = [super init];
    self.webpage = w;
    w->set_associated_frontend_tab_object_unsafe((__bridge void*)self);
    self.line1 = w->title().toNSString();
    self.line2 = w->title_2().toNSString();
    self.line3 = w->title_3().toNSString();
    self.outlineView = outlineView;
    QObject::connect(w.get(), &Webpage::propertyChanged, [=]() {
        [outlineView performSelectorOnMainThread:@selector(handleDataChanged:) withObject:self waitUntilDone:YES];
    });
    return self;
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    int index = [propertyList intValue];
    Webpage_ w = Global::searchDB->search_result()->webpage_(index);
    return [self initWithWebpage:w outlineView:nil];
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    if ([type isEqualToString:@"com.pointerbrowser.pasteboarditem.tab.searchresult"]) {
        return [NSNumber numberWithInt:Global::searchDB->search_result()->findTab(self.webpage)];
    }
    return nil;
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.searchresult"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.searchresult"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end

@implementation SearchResultGroupItem
- (instancetype)init
{
    self = [super init];
    self.children = [[NSMutableArray alloc] init];
    return self;
}
@end

@implementation WorkspaceTabItem
- (instancetype)initWithWebpage:(Webpage_)w tagContainer:(TagContainer_)container outlineView:(OutlineView*)outlineView
{
    self = [super init];
    self.webpage = w;
    w->set_associated_frontend_tab_object_unsafe((__bridge void*)self);
    self.tagContainer = container;
    self.title = w->title().toNSString();
    self.outlineView = outlineView;
    QObject::connect(w.get(), &Webpage::propertyChanged, [=]() {
        [outlineView performSelectorOnMainThread:@selector(handleDataChanged:) withObject:self waitUntilDone:YES];
    });
    return self;
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    int workspace_index = [propertyList[@"workspace_index"] intValue];
    int webpage_index = [propertyList[@"webpage_index"] intValue];
    TagContainer_ c = Global::controller->workspaces()->get(workspace_index);
    Webpage_ w = c->get(webpage_index);
    return [self initWithWebpage:w tagContainer:c outlineView:nil];
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    int workspace_index = Global::controller->workspaces()->indexOf(self.tagContainer);
    int webpage_index = self.tagContainer->indexOf(self.webpage);
    if ([type isEqualToString:@"com.pointerbrowser.pasteboarditem.tab.workspace"]) {
        return @{@"workspace_index": [NSNumber numberWithInt:workspace_index],
                 @"webpage_index": [NSNumber numberWithInt:webpage_index]};
    }
    return nil;
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.workspace"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.tab.workspace"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end

@implementation WorkspaceGroupItem
- (instancetype)initWithTagContainer:(TagContainer_)tagContainer outlineView:(OutlineView*)outlineView;
{
    self = [super init];
    self.children = [[NSMutableArray alloc] init];
    self.tagContainer = tagContainer;
    self.title = tagContainer->title().toNSString();
    self.outlineView = outlineView;
    QObject::connect(tagContainer.get(), &TagContainer::propertyChanged, [=]() {
        [self performSelectorOnMainThread:@selector(handleDataChanged:) withObject:self waitUntilDone:YES];
    });
    QObject::connect(&tagContainer->sig, &BaseListModelSignals::signal_tf_rows_inserted, [=](int index)
                     {
                         [outlineView performSelectorOnMainThread:@selector(handleWorkspaceTabsInserted:) withObject:@{@"parent": self, @"index":[NSNumber numberWithInt:index]} waitUntilDone:YES];
                     });
    QObject::connect(&tagContainer->sig, &BaseListModelSignals::signal_tf_rows_removed, [=](int index, int len)
                     {
                         [outlineView performSelectorOnMainThread:@selector(handleWorkspaceTabsRemoved:) withObject:@{@"parent": self, @"index":[NSNumber numberWithInt:index]} waitUntilDone:YES];
                     });
    QObject::connect(&tagContainer->sig, &BaseListModelSignals::signal_tf_model_reset, [=]()
                     {
                         [outlineView performSelectorOnMainThread:@selector(handleWorkspaceTabsReset:) withObject:self waitUntilDone:YES];
                     });
    QObject::connect(&tagContainer->sig, &BaseListModelSignals::signal_tf_rows_moved,
                     [=] (int from, int len, int to)
                     {
                         [outlineView performSelectorOnMainThread:@selector(handleWorkspaceTabsMoved:)
                                                withObject:@{@"from": [NSNumber numberWithInt:from],
                                                             @"to": [NSNumber numberWithInt:to],
                                                             @"parent": self}
                                             waitUntilDone:YES];
                     });
    return self;
}
- (instancetype)initWithPasteboardPropertyList:(id)propertyList ofType:(NSPasteboardType)type
{
    self = [super init];
    int workspace_index = [propertyList intValue];
    TagContainer_ c = Global::controller->workspaces()->get(workspace_index);
    self.tagContainer = c;
    return self;
}
- (id)pasteboardPropertyListForType:(NSPasteboardType)type
{
    int workspace_index = Global::controller->workspaces()->indexOf(self.tagContainer);
    return [NSNumber numberWithInt:workspace_index];
}
- (NSArray<NSPasteboardType> *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.group.workspace"];
}
+ (NSArray<NSPasteboardType> *)readableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    return @[@"com.pointerbrowser.pasteboarditem.group.workspace"];
}
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSPasteboardType)type pasteboard:(NSPasteboard *)pasteboard
{
    return NSPasteboardReadingAsPropertyList;
}
@end

@implementation OutlineView
- (OutlineView*)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    self.open_group_item = [[OpenGroupItem alloc] init];
    self.search_result_group_item = [[SearchResultGroupItem alloc] init];
    self.workspaces = [[NSMutableArray alloc] init];
    self.delegate = self;
    self.dataSource = self;
    [self connect];
    return self;
}

- (void)otherMouseDown:(NSEvent *)event
{
    [super otherMouseDown:event];
    NSPoint p = event.locationInWindow;
    NSPoint pt = [self convertPoint:p fromView:nil];
    int row = [self rowAtPoint:pt];
    if (row >= 0) {
        id item = [self itemAtRow:row];
        if ([item isKindOfClass:OpenTabItem.class]) {
            [item closeTab];
        }
    }
    Global::controller->closeAllPopoversAsync();
}

- (void)mouseDown:(NSEvent *)event
{
    [super mouseDown:event];
    Global::controller->closeAllPopoversAsync();
}

- (void)connect
{
    /* open tabs handlers */
    
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::rowsInserted,
                     [=] (const QModelIndex &parent, int first, int last)
    {
        [self performSelectorOnMainThread:@selector(handleOpenTabsInserted:)
                               withObject:@{@"first": [NSNumber numberWithInt:first],
                                            @"last": [NSNumber numberWithInt:last]}
                            waitUntilDone:YES];
    });
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::signal_tf_tab_moved,
                     [=] (int from, int to)
                     {
                         [self performSelectorOnMainThread:@selector(handleOpenTabsMoved:)
                                                withObject:@{@"from": [NSNumber numberWithInt:from],
                                                             @"to": [NSNumber numberWithInt:to]}
                                             waitUntilDone:YES];
                     });
    
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last)
    {
        [self performSelectorOnMainThread:@selector(handleOpenTabsRemoved:)
                               withObject:@{@"first": [NSNumber numberWithInt:first],
                                            @"last": [NSNumber numberWithInt:last]}
                            waitUntilDone:YES];
    });
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::modelReset,
                     [=]()
    {
        [self performSelectorOnMainThread:@selector(handleOpenTabsReset) withObject:nil waitUntilDone:YES];
    });

    /* search result handlers */
    
    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsInserted,
                     [=](const QModelIndex &parent, int first, int last)
                     {
                         [self performSelectorOnMainThread:@selector(handleSearchResultsInserted:)
                                                withObject:@{@"first": [NSNumber numberWithInt:first],
                                                             @"last": [NSNumber numberWithInt:last]}
                                             waitUntilDone:YES];
                     });
    
    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last)
                     {
                         [self performSelectorOnMainThread:@selector(handleSearchResultsRemoved:)
                                                withObject:@{@"first": [NSNumber numberWithInt:first],
                                                             @"last": [NSNumber numberWithInt:last]}
                                             waitUntilDone:YES];
                     });
    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::modelReset,
                     [=]()
     {
         [self performSelectorOnMainThread:@selector(handleSearchResultsReset) withObject:nil waitUntilDone:YES];
     });
    
    /* workspace handlers */
    QObject::connect(&Global::controller->workspaces()->sig, &BaseListModelSignals::signal_tf_rows_inserted,
                     [=](int first, int len)
    {
         [self performSelectorOnMainThread:@selector(handleWorkspaceInserted:)
                                withObject:[NSNumber numberWithInt:first]
                             waitUntilDone:YES];
    });
    QObject::connect(&Global::controller->workspaces()->sig, &BaseListModelSignals::signal_tf_model_reset,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handleWorkspaceReset)
                                                withObject:nil
                                             waitUntilDone:YES];
                     });
    QObject::connect(&Global::controller->workspaces()->sig, &BaseListModelSignals::signal_tf_rows_moved,
                     [=](int first, int len, int to)
                     {
                         [self performSelectorOnMainThread:@selector(handleWorkspaceMoved:)
                                                withObject:@{@"from": [NSNumber numberWithInt:first],
                                                             @"to": [NSNumber numberWithInt:to]}
                                             waitUntilDone:YES];
                     });
    QObject::connect(&Global::controller->workspaces()->sig, &BaseListModelSignals::signal_tf_rows_removed,
                     [=](int first, int len)
                     {
                         [self performSelectorOnMainThread:@selector(handleWorkspaceRemoved:)
                                                withObject:[NSNumber numberWithInt:first]
                                             waitUntilDone:YES];
                     });
    /* other handlers */
    
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_changed,
                     [=](Webpage_ w, void const* sender) {
                         if (sender == (__bridge void*)self) { return; }
                         [self performSelectorOnMainThread:@selector(handleIndexesChangesInController) withObject:nil waitUntilDone:YES];
                     });
    
    /* initial loads */
    [self handleOpenTabsReset];
    [self handleSearchResultsReset];
    [self handleWorkspaceReset];
}

- (void)handleIndexesChangesInController
{
    if (Global::controller->current_tab_state() == Controller::TabStateNull) {
        [self deselectAll:self];
        return;
    }
    if (Global::controller->current_tab_state() == Controller::TabStateOpen) {
        OpenTabItem* item = (__bridge OpenTabItem*)Global::controller->current_tab_webpage()->associated_frontend_tab_object();
        int row = [self rowForItem:item];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(row)];
        [self selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
    if (Global::controller->current_tab_state() == Controller::TabStatePreview) {
        SearchResultTabItem* item = (__bridge SearchResultTabItem*)Global::controller->current_tab_webpage()->associated_frontend_tab_object();
        int row = [self rowForItem:item];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(row)];
        [self selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
    if (Global::controller->current_tab_state() == Controller::TabStateWorkspace) {
        WorkspaceTabItem* item = (__bridge WorkspaceTabItem*)Global::controller->current_tab_webpage()->associated_frontend_tab_object();
        int row = [self rowForItem:item];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(row)];
        [self selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
}

- (NSUInteger)workspacesOffset
{
    return 1;
}

- (NSUInteger)openTabsOffset
{
    return 0;
}

- (NSUInteger)searchResultsOffset
{
    return Global::controller->workspaces()->count() + 1;
}

- (void)handleWorkspaceInserted:(NSNumber*)index
{
    int idx = index.intValue;
    TagContainer_ c = Global::controller->workspaces()->get(idx);
    WorkspaceGroupItem* item = [[WorkspaceGroupItem alloc] initWithTagContainer:c outlineView:self];
    [self.workspaces insertObject:item atIndex:idx];
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndex:idx + self.workspacesOffset];
    [self beginUpdates];
    [self insertItemsAtIndexes:range inParent:nil withAnimation:NSTableViewAnimationEffectFade];
    [self endUpdates];
    [self handleWorkspaceTabsReset:item];
    [self expandItem:item expandChildren:YES];
}

- (void)handleWorkspaceTabsInserted:(NSDictionary*)dict
{
    int idx = [dict[@"index"] intValue];
    WorkspaceGroupItem* parent = dict[@"parent"];
    TagContainer_ c = parent.tagContainer;
    Webpage_ w = c->get(idx);
    WorkspaceTabItem* item = [[WorkspaceTabItem alloc] initWithWebpage:w tagContainer:c outlineView:self];
    [parent.children insertObject:item atIndex:idx];
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndex:idx];
    [self beginUpdates];
    [self insertItemsAtIndexes:range inParent:parent withAnimation:NSTableViewAnimationEffectGap];
    [self endUpdates];
}

- (void)handleWorkspaceTabsRemoved:(NSDictionary*)dict
{
    int idx = [dict[@"index"] intValue];
    int len = [dict[@"length"] intValue];
    WorkspaceGroupItem* parent = dict[@"parent"];
    TagContainer_ c = parent.tagContainer;
    WorkspaceTabItem* item = parent.children[idx];
    Webpage_ w = item.webpage;
    w->disconnect();
    [parent.children removeObjectAtIndex:idx];
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndex:idx];
    [self beginUpdates];
    [self removeItemsAtIndexes:range inParent:parent withAnimation:NSTableViewAnimationSlideUp];
    [self endUpdates];
}

- (void)handleWorkspaceMoved:(NSDictionary*)dict
{
    int from = [dict[@"from"] intValue];
    int to = [dict[@"to"] intValue];
    WorkspaceGroupItem* item = self.workspaces[from];
    [self.workspaces removeObjectAtIndex:from];
    [self.workspaces insertObject:item atIndex:(from < to ? to - 1 : to)];
    [self reloadItem:nil reloadChildren:YES];
}

- (void)handleWorkspaceReset
{
    // possible memory leak of QT connections
    [self.workspaces removeAllObjects];
    for (int i = Global::controller->workspaces()->count() - 1; i >= 0; i--) {
        TagContainer_ c = Global::controller->workspaces()->get(i);
        WorkspaceGroupItem* item = [[WorkspaceGroupItem alloc] initWithTagContainer:c outlineView:self];
        [self.workspaces insertObject:item atIndex:0];
        [self handleWorkspaceTabsReset:item];
    }
    [self reloadItem:nil reloadChildren:YES];
}

- (void)handleWorkspaceTabsMoved:(NSDictionary*)dict
{
    int from = [dict[@"from"] intValue];
    int to = [dict[@"to"] intValue];
    WorkspaceGroupItem* parent = dict[@"parent"];
    TagContainer_ c = parent.tagContainer;
    WorkspaceTabItem* item = parent.children[from];
    [parent.children removeObjectAtIndex:from];
    [parent.children insertObject:item atIndex:(from < to ? to - 1 : to)];
    [self reloadItem:parent reloadChildren:YES];
}

- (void)handleWorkspaceTabsReset:(WorkspaceGroupItem*)parent
{
    TagContainer_ tagContainer = parent.tagContainer;
    NSMutableIndexSet* old_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, parent.children.count)];
    [parent.children removeAllObjects];
    for (int i = 0; i < tagContainer->count(); i++) {
        Webpage_ w = tagContainer->get(i);
        WorkspaceTabItem* item = [[WorkspaceTabItem alloc] initWithWebpage:w tagContainer:tagContainer outlineView:self];
        [parent.children insertObject:item atIndex:i];
    }
    NSMutableIndexSet* new_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, parent.children.count)];
    
    [self beginUpdates];
    [self removeItemsAtIndexes:old_range inParent:parent withAnimation:NSTableViewAnimationEffectNone];
    [self insertItemsAtIndexes:new_range inParent:parent withAnimation:NSTableViewAnimationEffectNone];
    [self endUpdates];
}


- (void)handleWorkspaceRemoved:(NSNumber*)index
{
    int idx = index.intValue;
    WorkspaceGroupItem* item = self.workspaces[idx];
    item.tagContainer->disconnect();
    // remove individual tabs first
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, item.children.count)];
    for (int i = item.children.count - 1; i >= 0; i--) {
        WorkspaceTabItem* tab = item.children[i];
        tab.webpage->disconnect();
    }
    [self beginUpdates];
    [self removeItemsAtIndexes:indexes inParent:item withAnimation:NSTableViewAnimationSlideUp];
    [self endUpdates];
    // remove workspace
    [self.workspaces removeObjectAtIndex:idx];
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndex:idx + self.workspacesOffset];
    [self beginUpdates];
    [self removeItemsAtIndexes:range inParent:nil withAnimation:NSTableViewAnimationEffectFade];
    [self endUpdates];
}

- (void)handleOpenTabsReset
{
    NSMutableIndexSet* old_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.open_group_item.children.count)];
    
    [self.open_group_item.children removeAllObjects];
    int count_open_tabs = Global::controller->open_tabs()->count();
    for (int i = 0; i < count_open_tabs; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        OpenTabItem* item = [[OpenTabItem alloc] initWithWebpage:w outlineView:self];
        [self.open_group_item.children insertObject:item atIndex:i];
    }
    NSMutableIndexSet* new_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.open_group_item.children.count)];
    
    [self beginUpdates];
    [self removeItemsAtIndexes:old_range inParent:self.open_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self insertItemsAtIndexes:new_range inParent:self.open_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self endUpdates];
}

- (void)handleSearchResultsReset
{
    int count = Global::searchDB->search_result()->count();
    if ((self.search_result_group_item.children.count == 0 && count > 0)
        || (self.search_result_group_item.children.count > 0 && count == 0))
    {
        [self reloadItem:self.search_result_group_item reloadChildren:NO];
    }
    NSMutableIndexSet* old_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.search_result_group_item.children.count)];
    [self.search_result_group_item.children removeAllObjects];
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::searchDB->search_result()->webpage_(i);
        SearchResultTabItem* item = [[SearchResultTabItem alloc] initWithWebpage:w outlineView:self];
        [self.search_result_group_item.children insertObject:item atIndex:i];
    }
    NSMutableIndexSet* new_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.search_result_group_item.children.count)];
    
    [self beginUpdates];
    [self removeItemsAtIndexes:old_range inParent:self.search_result_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self insertItemsAtIndexes:new_range inParent:self.search_result_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self endUpdates];
}

- (void)handleOpenTabsInserted:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    for (int i = first; i <= last; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        OpenTabItem* item = [[OpenTabItem alloc] initWithWebpage:w outlineView:self];
        [self.open_group_item.children insertObject:item atIndex:i];
    }
    
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(first, last-first+1)];
    [self beginUpdates];
    [self insertItemsAtIndexes:range inParent:self.open_group_item withAnimation:NSTableViewAnimationEffectGap];
    [self endUpdates];
}

- (void)handleOpenTabsRemoved:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(first, last-first+1)];
    [self.open_group_item.children removeObjectsAtIndexes:range];
    
    NSIndexSet* selected = self.selectedRowIndexes;
    
    [self beginUpdates];
    [self deselectAll:self];
    [self removeItemsAtIndexes:range inParent:self.open_group_item withAnimation:NSTableViewAnimationSlideUp];
    if (Global::controller->current_tab_state() == Controller::TabStatePreview) {
        NSIndexSet* new_selected;
        new_selected = [NSIndexSet indexSetWithIndex:[selected firstIndex] - 1];
        [self selectRowIndexes:new_selected byExtendingSelection:NO];
    }
    [self endUpdates];
}

- (void)handleSearchResultsInserted:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    if ((self.search_result_group_item.children.count == 0 && Global::searchDB->search_result()->count() > 0)
        || (self.search_result_group_item.children.count > 0 && Global::searchDB->search_result()->count() == 0))
    {
        [self reloadItem:self.search_result_group_item reloadChildren:NO];
    }
    
    NSMutableIndexSet* inserted = [[NSMutableIndexSet alloc] init];
    for (int i = first; i <= last; i++) {
        Webpage_ w = Global::searchDB->search_result()->webpage_(i);
        SearchResultTabItem* item = [[SearchResultTabItem alloc] initWithWebpage:w outlineView:self];
        [self.search_result_group_item.children insertObject:item atIndex:i];
        [inserted addIndex:i];
    }
    
    [self beginUpdates];
    [self insertItemsAtIndexes:inserted inParent:self.search_result_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self endUpdates];
}

- (void)handleOpenTabsMoved:(NSDictionary*)indices
{
    int from = [indices[@"from"] intValue];
    int to = [indices[@"to"] intValue];
    id item = self.open_group_item.children[from];
    [self.open_group_item.children removeObjectAtIndex:from];
    [self.open_group_item.children insertObject:item atIndex:(from < to ? to - 1 : to)];
    [self reloadItem:self.open_group_item reloadChildren:YES];
}

- (void)handleSearchResultsRemoved:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    if ((self.search_result_group_item.children.count == 0 && Global::searchDB->search_result()->count() > 0)
        || (self.search_result_group_item.children.count > 0 && Global::searchDB->search_result()->count() == 0))
    {
        [self reloadItem:self.search_result_group_item reloadChildren:NO];
    }
    
    NSMutableIndexSet* removed = [[NSMutableIndexSet alloc] init];
    for (int i = first; i <= last; i++) {
        [self.search_result_group_item.children removeObjectAtIndex:i];
        [removed addIndex:i];
    }
    [self reloadItem:self.search_result_group_item reloadChildren:NO];
    [self beginUpdates];
    [self removeItemsAtIndexes:removed inParent:self.search_result_group_item withAnimation:NSTableViewAnimationEffectNone];
    [self endUpdates];
    
}

- (void)handleDataChanged:(id)item
{
    if ([item isKindOfClass:OpenTabItem.class]
        || [item isKindOfClass:WorkspaceTabItem.class])
    {
        [item setTitle:[item webpage]->title().toNSString()];
    } else if ([item isKindOfClass:SearchResultTabItem.class]) {
        [item setLine1:[item webpage]->title().toNSString()];
        [item setLine2:[item webpage]->title_2().toNSString()];
        [item setLine3:[item webpage]->title_3().toNSString()];
    } else if ([item isKindOfClass:WorkspaceGroupItem.class]) {
        [item setTitle:[item tagContainer]->title().toNSString()];
    }
    [self reloadItem:item reloadChildren:NO];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)parent
{
    if (parent == nil) {
        if (index == 0) {
            return self.open_group_item;
        }
        if (1 <= index && index <= self.workspaces.count) {
            return self.workspaces[index - 1];
        }
        if (index > self.workspaces.count) {
            return self.search_result_group_item;
        }
    }
    if ([parent isKindOfClass:OpenGroupItem.class]) {
        return [parent children][index];
    }
    if ([parent isKindOfClass:SearchResultGroupItem.class]) {
        return [parent children][index];
    }
    if ([parent isKindOfClass:WorkspaceGroupItem.class]) {
        return [parent children][index];
    }
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    // For the groups, we just return a regular text view.
    if ([item isKindOfClass:OpenGroupItem.class]) {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Open Tabs";
        return result;
    }
    if ([item isKindOfClass:SearchResultGroupItem.class]) {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Discoveries";
        result.hidden = (Global::searchDB->search_result()->count() == 0);
        return result;
    }
    if ([item isKindOfClass:WorkspaceGroupItem.class]) {
        TrackingAreaCellView* result = [outlineView makeViewWithIdentifier:@"WorkspaceHeaderRowView" owner:self];
        result.item = item;
        result.outlineView = self;
        result.hovered = NO;
        result.objectValue = ("Tag: " + [item tagContainer]->title()).toNSString();
        return result;
    }
    if ([item isKindOfClass:OpenTabItem.class])
    {
        TrackingAreaCellView* result = [outlineView makeViewWithIdentifier:@"OpenTabRowView" owner:self];
        result.item = item;
        result.outlineView = self;
        result.hovered = NO;
        result.objectValue = item;
        return result;
    }
    if ([item isKindOfClass:SearchResultTabItem.class])
    {
        NSTableCellView* result = [outlineView makeViewWithIdentifier:@"SearchResultsRowView" owner:self];
        result.objectValue = item;
        return result;
    }
    if ([item isKindOfClass:WorkspaceTabItem.class])
    {
        NSTableCellView* result = [outlineView makeViewWithIdentifier:@"WorkspaceTabRowView" owner:self];
        result.objectValue = item;
        return result;
    }
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView
     heightOfRowByItem:(id)item
{
    if ([item isKindOfClass:OpenGroupItem.class]
        || [item isKindOfClass:SearchResultGroupItem.class]
        || [item isKindOfClass:WorkspaceGroupItem.class])
    {
        return 23;
    }
    if ([item isKindOfClass:OpenTabItem.class])
    {
        return 30;
    }
    if ([item isKindOfClass:WorkspaceTabItem.class])
    {
        return 30;
    }
    if ([item isKindOfClass:SearchResultTabItem.class])
    {
        return 60;
    }
    return 0;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return 2 + self.workspaces.count;
    }
    if ([item isKindOfClass:OpenGroupItem.class]) {
        return [item children].count;
    }
    if ([item isKindOfClass:SearchResultGroupItem.class]) {
        return [item children].count;
    }
    if ([item isKindOfClass:WorkspaceGroupItem.class]) {
        return [item children].count;
    }
    return 0;
}


- (BOOL)isHeader:(id)item
{
    if (item == nil) {
        return YES;
    }
    if ([item isKindOfClass:OpenGroupItem.class]) {
        return YES;
    }
    if ([item isKindOfClass:SearchResultGroupItem.class]) {
        return YES;
    }
    if ([item isKindOfClass:WorkspaceGroupItem.class]) {
        return YES;
    }
    return NO;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    return [self isHeader:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(id)item
{
    if ([self isHeader:item]) {
        return false;
    }
    if ([item isKindOfClass:OpenTabItem.class]) {
        return true;
    }
    if ([item isKindOfClass:WorkspaceTabItem.class]) {
        return YES;
    }
    if ([item isKindOfClass:SearchResultTabItem.class]) {
        return ! Global::controller->crawler_rule_table_visible();
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (IBAction)clicked:(id)sender
{
    Global::controller->closeAllPopoversAsync();
}

- (IBAction)doubleClicked:(id)sender
{
    NSInteger index = [self clickedRow] - Global::controller->open_tabs()->count() - 2; // -2 for labels
    if (index >= 0) {
        // clicked on search result
        Webpage_ p = Global::searchDB->search_result()->webpage_(static_cast<int>(index));
        Global::controller->newTabAsync(Controller::TabStateOpen,
                                        p->url(),
                                        Controller::WhenCreatedViewNew,
                                        Controller::WhenExistsViewExisting);
    }
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSInteger row_to_select = [notification.object selectedRow];
    if (row_to_select == -1) { return; }
    id item = [self itemAtRow:row_to_select];
    NSInteger index = row_to_select - Global::controller->open_tabs()->count() - 2; // -2 for labels
    if ([item isKindOfClass:SearchResultTabItem.class]) {
        // clicked on search result
        Webpage_ w = [item webpage];
        Global::controller->newTabAsync(Controller::TabStatePreview,
                                        w->url(),
                                        Controller::WhenCreatedViewNew,
                                        Controller::WhenExistsViewExisting);
        return;
    }
    if ([item isKindOfClass:WorkspaceTabItem.class]) {
        // clicked on search result
        Webpage_ w = [item webpage];
        Global::controller->newTabByWebpageCopyAsync(0, Controller::TabStateWorkspace, w,
                                        Controller::WhenCreatedViewNew,
                                        Controller::WhenExistsViewExisting);
        return;
    }
    if ([item isKindOfClass:OpenTabItem.class]) {
        // clicked on open tab
        int index = [self childIndexForItem:item];
        Global::controller->viewTabAsync(Controller::TabStateOpen, static_cast<int>(index), (__bridge void*)self);
        return;
    }
}

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView
               pasteboardWriterForItem:(id)item
{
    if ([item isKindOfClass:OpenTabItem.class]
        || [item isKindOfClass:SearchResultTabItem.class]
        || [item isKindOfClass:WorkspaceTabItem.class])
    {
        int row = [outlineView rowForItem:item];
        [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
        return item;
    } else if ([item isKindOfClass:WorkspaceGroupItem.class]) {
        return item;
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(id)dropLocation
         childIndex:(NSInteger)new_index
{
    NSPasteboard* pasteboard = info.draggingPasteboard;
    NSArray<id>* boarditems = [pasteboard readObjectsForClasses:@[SearchResultTabItem.class, OpenTabItem.class, WorkspaceTabItem.class, WorkspaceGroupItem.class] options:nil];
    [boarditems enumerateObjectsUsingBlock:^(id  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop)
    {
        // dropping on root
        if (dropLocation == nil) {
            // moving workspace group
            if ([item isKindOfClass:WorkspaceGroupItem.class]) {
                int offset = self.workspacesOffset;
                TagContainer_ c = [item tagContainer];
                int old_index = Global::controller->workspaces()->indexOf(c);
                Global::controller->workspacesMoveTagContainerAsync(old_index, new_index - offset);
            }
        }
        // dropping on open group
        else if ([dropLocation isKindOfClass:OpenGroupItem.class]) {
            // moving open tab
            if ([item isKindOfClass:OpenTabItem.class]) {
                Webpage_ w = [item webpage];
                int index = Global::controller->open_tabs()->findTab(w);
                Global::controller->moveTabAsync(Controller::TabStateOpen, index, Controller::TabStateOpen, new_index, (__bridge void*)self);
            }
            // dragging search result
            else if ([item isKindOfClass:SearchResultTabItem.class]) {
                Webpage_ w = [item webpage];
                Global::controller->newTabAsync(new_index, Controller::TabStateOpen, w->url(), Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew, (__bridge void*)self);
            }
            // dragging workspace tab
            else if ([item isKindOfClass:WorkspaceTabItem.class]) {
                TagContainer_ c = [item tagContainer];
                Webpage_ w = [item webpage];
                Global::controller->newTabAsync(new_index, Controller::TabStateOpen, w->url(), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
                Global::controller->tagContainerRemoveWebpageAsync(c, w);
            }
        }
        // dropping on a workspace group
        else if ([dropLocation isKindOfClass:WorkspaceGroupItem.class]) {
            // dragging search result or open tab
            if ([item isKindOfClass:SearchResultTabItem.class] || [item isKindOfClass:OpenTabItem.class])
            {
                TagContainer_ c = [dropLocation tagContainer];
                Webpage_ w = [item webpage];
                Global::controller->tagContainerInsertWebpageCopyAsync(c, new_index, w);
            }
            // dragging a workpace item
            else if ([item isKindOfClass:WorkspaceTabItem.class]) {
                Webpage_ w = [item webpage];
                if ([item tagContainer] == [dropLocation tagContainer]) {
                    // within the same container, move
                    TagContainer_ c = [item tagContainer];
                    int old_index = c->indexOfUrl(w->url());
                    if (old_index == new_index || new_index == old_index + 1) {
                        // ignore
                        return;
                    }
                    Global::controller->tagContainerMoveWebpageAsync(c, old_index, new_index);
                } else {
                    // otherwise copy
                    Global::controller->tagContainerInsertWebpageCopyAsync([dropLocation tagContainer], new_index, w);
                }
            }
        }
    }];
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)parent
            proposedChildIndex:(NSInteger)index
{
    NSPasteboard* pasteboard = info.draggingPasteboard;
    // dropping on root
    if (parent == nil) {
//        // dragging a workspace around
//        if ([pasteboard canReadObjectForClasses:@[WorkspaceGroupItem.class] options:nil]) {
//            if (index < 1) {
//                int offset = self.searchResultsOffset;
//                [outlineView setDropItem:nil dropChildIndex:offset];
//            }
//            return NSDragOperationMove;
//        }
        return NSDragOperationNone;
    }
    // dropping on open tab group
    else if ([parent isKindOfClass:OpenGroupItem.class]) {
        // moving open tab
        if ([pasteboard canReadObjectForClasses:@[OpenTabItem.class] options:nil]) {
            if (index < 0) {
                [outlineView setDropItem:parent dropChildIndex:0];
            }
            return NSDragOperationMove;
        }
        // moving workspace tab to open tab group
        if ([pasteboard canReadObjectForClasses:@[WorkspaceTabItem.class] options:nil]) {
            if (index < 0) {
                [outlineView setDropItem:parent dropChildIndex:0];
            }
            return NSDragOperationDelete;
        }
        // dragging a workspace around, redirect
        if ([pasteboard canReadObjectForClasses:@[WorkspaceGroupItem.class] options:nil]) {
            [outlineView setDropItem:nil dropChildIndex:self.workspacesOffset];
            return NSDragOperationMove;
        }
        // dragging a search result
        if ([pasteboard canReadObjectForClasses:@[SearchResultTabItem.class] options:nil]) {
            if (index < 0) {
                [outlineView setDropItem:parent dropChildIndex:0];
            }
            return NSDragOperationCopy;
        }
    }
    // dropping on a workspace group (any)
    else if ([parent isKindOfClass:WorkspaceGroupItem.class]) {
        // dragging a workspace tab around
        if ([pasteboard canReadObjectForClasses:@[WorkspaceTabItem.class] options:nil]) {
            if (index < 0) {
                [outlineView setDropItem:parent dropChildIndex:0];
            }
            WorkspaceTabItem* item = [pasteboard readObjectsForClasses:@[WorkspaceTabItem.class] options:nil][0];
            if ([parent tagContainer] == [item tagContainer]) {
                return NSDragOperationMove;
            } else {
                return NSDragOperationCopy;
            }
        }
        // dragging a open tab around
        if ([pasteboard canReadObjectForClasses:@[OpenTabItem.class, SearchResultTabItem.class] options:nil]) {
            if (index < 0) {
                [outlineView setDropItem:parent dropChildIndex:0];
            }
            return NSDragOperationCopy;
        }
        // dragging a workspace around, redirect
        if ([pasteboard canReadObjectForClasses:@[WorkspaceGroupItem.class] options:nil]) {
//            WorkspaceGroupItem* item = [pasteboard readObjectsForClasses:@[WorkspaceGroupItem.class] options:nil][0];
//            int parent_index = [outlineView childIndexForItem:parent];
//            int current_index = [self rowForItem:item];
//            if (current_index - 1 <= index && index <= current_index + 1) {
//                return NSDragOperationNone;
//            }
//            [outlineView setDropItem:nil dropChildIndex:parent_index];
            return NSDragOperationNone;
//            return NSDragOperationMove;
        }
    }
    // dropping on search results
    else if ([parent isKindOfClass:SearchResultGroupItem.class]) {
        if ([pasteboard canReadObjectForClasses:@[WorkspaceGroupItem.class] options:nil]) {
            int parent_index = [outlineView childIndexForItem:parent];
            [outlineView setDropItem:nil dropChildIndex:parent_index];
            return NSDragOperationMove;
        }
    }
    return NSDragOperationNone;
}

- (NSRect)frameOfCellAtColumn:(NSInteger)column row:(NSInteger)row {
    NSRect superFrame = [super frameOfCellAtColumn:column row:row];
    NSView* reference = self.enclosingScrollView;
    superFrame.origin.x = 0;
    int rightX = reference.frame.origin.x + reference.frame.size.width;
    superFrame.size.width = rightX - superFrame.origin.x;
    return superFrame;
}

- (NSMenu*)menuForEvent:(NSEvent *)event
{
    Global::controller->emit_tf_close_all_popovers();
    NSPoint p = event.locationInWindow;
    NSPoint pt = [self convertPoint:p fromView:nil];
    int row = [self rowAtPoint:pt];
    id item = [self itemAtRow:row];
    if ([self isHeader:item]) {
        return nil;
    }
    [self selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
    if ([item isKindOfClass:OpenTabItem.class]) {
        return self.open_tab_menu;
    }
    if ([item isKindOfClass:SearchResultTabItem.class]) {
        return self.search_result_tab_menu;
    }
    if ([item isKindOfClass:WorkspaceTabItem.class]) {
        [self.workspace_tab_menu listRemoveTabOptionsForTagContainer:[item tagContainer] webpage:[item webpage]];
        return self.workspace_tab_menu;
    }
    return nil;
}
@end

@implementation OutlineViewController
- (NSNibName)nibName
{
    return @"OutlineView";
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    [self.outlineView registerForDraggedTypes:@[NSPasteboardTypeURL, @"com.pointerbrowser.pasteboarditem.tab.open", @"com.pointerbrowser.pasteboarditem.tab.searchresult", @"com.pointerbrowser.pasteboarditem.tab.workspace", @"com.pointerbrowser.pasteboarditem.group.workspace"]];
    [self.outlineView expandItem:nil expandChildren:YES];
    [self.outlineView handleIndexesChangesInController];
}

- (void)showAddTagsPopoverForCurrentTab:(id)sender
{
    NSRect frame = [self.outlineView frameOfOutlineCellAtRow:self.outlineView.selectedRow];
    NSView* cell = [self.outlineView rowViewAtRow:self.outlineView.selectedRow makeIfNecessary:YES];
    Webpage_ w = Global::controller->current_tab_webpage();
    [self.add_tags_popover showForWebpage:w relativeToRect:frame ofView:cell preferredEdge:NSMaxXEdge];
}
@end

@implementation RemoveTagMenuItem
- (instancetype)initWithContainer:(TagContainer_)container webpage:(Webpage_)webpage
{
    self = [super init];
    self.tagContainer = container;
    self.webpage = webpage;
    self.title = @"Remove Tag";//[NSString stringWithFormat:@"Untag \"%\" \"%@\"",container->title().toNSString()];
    self.target = self;
    self.action = @selector(handleClicked:);
    self.keyEquivalentModifierMask = NSEventModifierFlagCommand;
    unichar back = NSBackspaceCharacter;
    self.keyEquivalent = [NSString stringWithCharacters:&back length:1];
    return self;
}
- (void)handleClicked:(id)sender
{
    Global::controller->tagContainerRemoveWebpageAsync(self.tagContainer, self.webpage);
}
@end

@implementation WorkspaceTabItemMenu
- (void)listRemoveTabOptionsForTagContainer:(TagContainer_)c webpage:(Webpage_)w
{
//    NSArray<NSMenuItem*>* items = self.itemArray;
//    for (int i = 0; i < items.count; i++) {
//        NSMenuItem* item = items[i];
//        if ([item isKindOfClass:RemoveTagMenuItem.class]) {
//            [self remove]
//        }
//    }
    if ([self.itemArray[0] isKindOfClass:RemoveTagMenuItem.class]) {
        [self removeItemAtIndex:0];
    }
    RemoveTagMenuItem* newItem = [[RemoveTagMenuItem alloc] initWithContainer:c webpage:w];
    [self insertItem:newItem atIndex:0];
}
@end

@implementation OpenTabItemMenu
@end

@implementation SearchResultTabItemMenu
@end
