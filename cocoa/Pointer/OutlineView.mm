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

@implementation OpenTabCellView
@synthesize line1 = m_line1;
@synthesize hovered = m_hovered;
@synthesize outline = m_outline;
@synthesize data_item = m_data_item;
@synthesize tracking_area = m_tracking_area;
@synthesize webpage = m_webpage;

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    self.hovered = NO;
    self.tracking_area = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingMouseEnteredAndExited|NSTrackingActiveInKeyWindow owner:self userInfo:nil];
    [self addTrackingArea:self.tracking_area];
    return self;
}

- (void)dealloc
{
}

- (void)mouseEntered:(NSEvent *)event
{
    self.hovered = YES;
    [super mouseEntered:event];
}

- (void)mouseExited:(NSEvent *)event
{
    self.hovered = NO;
    [super mouseExited:event];
}

- (void)otherMouseDown:(NSEvent*)event
{
    NSInteger button = event.buttonNumber;
    if (button == 2) {
        [self closeTab:self];
    }
}

- (IBAction)closeTab:(id)sender
{
    NSInteger index = [self.outline childIndexForItem:self.data_item];
    Global::controller->closeTabAsync(Controller::TabStateOpen, static_cast<int>(index));
}

@end


@implementation SearchResultCellView
@synthesize line1 = m_line1;
@synthesize line2 = m_line2;
@synthesize line3 = m_line3;
@synthesize webpage = m_webpage;
@end

@implementation TabsList

@synthesize type = m_type;
@synthesize label = m_label;
@synthesize tabs = m_tabs;

- (TabsList*) initType:(TabsListType)type
                 label:(NSString*)label
{
    self = [super init];
    self.type = type;
    self.label = label;
    self.tabs = nil;
    return self;
}
@end

@implementation OutlineViewDelegateAndDataSource

@synthesize outline = m_outline;
@synthesize currently_hovered_opentab_cellview = m_currently_hovered_opentab_cellview;
@synthesize open_tabs = m_open_tabs;
@synthesize search_results = m_search_results;

- (OutlineViewDelegateAndDataSource*)init
{
    self = [super init];
    self->m_open_tabs = [MutableArrayWrapper wrap:[[NSMutableArray alloc] init]];
    self->m_search_results = [MutableArrayWrapper wrap:[[NSMutableArray alloc] init]];
    [self connect];
    return self;
}

- (void)connect
{
//    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsInserted,
//                     [=](const QModelIndex &parent, int first, int last)
//    {
//        [self performSelectorOnMainThread:@selector(handleSearchResultsInserted:)
//                               withObject:@{@"first": [NSNumber numberWithInt:first],
//                                            @"last": [NSNumber numberWithInt:last]}
//                            waitUntilDone:YES];
//    });
//
//    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsRemoved,
//                     [=](const QModelIndex &parent, int first, int last)
//    {
//        [self performSelectorOnMainThread:@selector(handleSearchResultsRemoved:)
//                               withObject:@{@"first": [NSNumber numberWithInt:first],
//                                            @"last": [NSNumber numberWithInt:last]}
//                            waitUntilDone:YES];
//    });
 
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

    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::modelReset,
                     [=]()
     {
         [self performSelectorOnMainThread:@selector(handleSearchResultsReset) withObject:nil waitUntilDone:YES];
     });
    
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_changed,
                     [=](Webpage_ w, void const* sender) {
                         if (sender == (__bridge void*)self) { return; }
                         [self performSelectorOnMainThread:@selector(updateSelection) withObject:nil waitUntilDone:YES];
                     });
    [self reloadAll];
}

- (void)updateSelection
{
    if (Global::controller->current_tab_state() == Controller::TabStateNull) {
        [self.outline deselectAll:self];
        return;
    }
    int i = Global::controller->current_open_tab_highlight_index();
    if (i >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(i + 1)]; // +1 for label
        [self.outline selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
    int j = Global::controller->current_tab_search_highlight_index();
    int offset = Global::controller->open_tabs()->count();
    if (j >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(j + offset + 2)]; // +2 for label
        [self.outline selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
}

// called when the search result changed
- (void)reloadAll
{
    [self handleOpenTabsReset];
    [self handleSearchResultsReset];
}

- (void)handleOpenTabsReset
{
    NSMutableIndexSet* old_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.open_tabs.get.count)];
    
    [self.open_tabs.get removeAllObjects];
    int count_open_tabs = Global::controller->open_tabs()->count();
    for (int i = 0; i < count_open_tabs; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        id item = [CppSharedData wrap:w];
        [self.open_tabs.get insertObject:item atIndex:i];
        QObject::connect(w.get(), &Webpage::dataChanged, [=]() {
            [self performSelectorOnMainThread:@selector(handleDataChanged:) withObject:item waitUntilDone:YES];
        });
    }
    NSMutableIndexSet* new_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.open_tabs.get.count)];
    
    [self.outline beginUpdates];
    [self.outline removeItemsAtIndexes:old_range inParent:self.open_tabs withAnimation:NSTableViewAnimationEffectNone];
    [self.outline insertItemsAtIndexes:new_range inParent:self.open_tabs withAnimation:NSTableViewAnimationEffectNone];
    [self.outline endUpdates];
}

- (void)handleSearchResultsReset
{
    NSMutableIndexSet* old_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.search_results.get.count)];
    
    [self.search_results.get removeAllObjects];
    int count = Global::searchDB->search_result()->count();
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::searchDB->search_result()->webpage_(i);
        id item = [CppSharedData wrap:w];
        [self.search_results.get insertObject:item atIndex:i];
    }
    NSMutableIndexSet* new_range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, self.search_results.get.count)];
    
    [self.outline beginUpdates];
    [self.outline removeItemsAtIndexes:old_range inParent:self.search_results withAnimation:NSTableViewAnimationEffectNone];
    [self.outline insertItemsAtIndexes:new_range inParent:self.search_results withAnimation:NSTableViewAnimationEffectNone];
    [self.outline endUpdates];
}

- (void)handleOpenTabsInserted:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    for (int i = first; i <= last; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        CppSharedData* item = [CppSharedData wrap:w];
        [self.open_tabs.get insertObject:item atIndex:i];
        QObject::connect(w.get(), &Webpage::dataChanged, [=]() {
            [self performSelectorOnMainThread:@selector(handleDataChanged:) withObject:item waitUntilDone:YES];
        });
    }
    
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(first, last-first+1)];
    [self.outline beginUpdates];
    [self.outline insertItemsAtIndexes:range inParent:self.open_tabs withAnimation:NSTableViewAnimationEffectGap];
    [self.outline endUpdates];
}

- (void)handleOpenTabsRemoved:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    
    NSMutableIndexSet* range = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(first, last-first+1)];
    [self.open_tabs.get removeObjectsAtIndexes:range];
    
    NSIndexSet* selected = self.outline.selectedRowIndexes;
    
    [self.outline beginUpdates];
    [self.outline deselectAll:self];
    [self.outline removeItemsAtIndexes:range inParent:self.open_tabs withAnimation:NSTableViewAnimationSlideUp];
    NSIndexSet* new_selected;
    if (Global::controller->current_tab_state() == Controller::TabStatePreview) {
        new_selected = [NSIndexSet indexSetWithIndex:[selected firstIndex] - 1];
    } else {
        new_selected = selected;
    }
    [self.outline selectRowIndexes:new_selected byExtendingSelection:NO];
    [self.outline endUpdates];
}

- (void)handleSearchResultsInserted:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    NSMutableIndexSet* inserted = [[NSMutableIndexSet alloc] init];
    for (int i = first; i <= last; i++) {
        Webpage_ w = Global::searchDB->search_result()->webpage_(i);
        id item = [CppSharedData wrap:w];
        [self.search_results.get insertObject:item atIndex:i];
        QObject::connect(w.get(), &Webpage::dataChanged, [=]() {
            [self performSelectorOnMainThread:@selector(handleDataChanged:) withObject:item waitUntilDone:YES];
        });
        [inserted addIndex:i];
    }
    [self.outline insertItemsAtIndexes:inserted inParent:self.search_results withAnimation:NSTableViewAnimationEffectNone];
}

- (void)handleOpenTabsMoved:(NSDictionary*)indices
{
    int from = [indices[@"from"] intValue];
    int to = [indices[@"to"] intValue];
    id item = self.open_tabs.get[from];
    [self.open_tabs.get removeObjectAtIndex:from];
    [self.open_tabs.get insertObject:item atIndex:(from < to ? to - 1 : to)];
//    [self handleOpenTabsReset];
    [self.outline reloadItem:nil reloadChildren:YES];
}

- (void)handleSearchResultsRemoved:(NSDictionary*)indices
{
    int first = [indices[@"first"] intValue];
    int last = [indices[@"last"] intValue];
    NSMutableIndexSet* removed = [[NSMutableIndexSet alloc] init];
    for (int i = first; i <= last; i++) {
        [self.search_results.get removeObjectAtIndex:i];
        [removed addIndex:i];
    }
    [self.outline removeItemsAtIndexes:removed inParent:self.search_results withAnimation:NSTableViewAnimationEffectNone];
}

- (void)handleDataChanged:(id)item
{
    [self.outline reloadItem:item reloadChildren:NO];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if (item == nil) {
        if (index == 0) {
            return self.open_tabs;
        }
        if (index == 1) {
            return self.search_results;
        }
    } else if (item == self.open_tabs) {
        return self.open_tabs.get[index];
    } else if (item == self.search_results) {
        return self.search_results.get[index];
    }
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    // For the groups, we just return a regular text view.
    if (item == self.open_tabs) {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Open Tabs";
        return result;
    }
    if (item == self.search_results) {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Discoveries";
        return result;
    }
    if ([outlineView parentForItem:item] == self.open_tabs)
    {
        OpenTabCellView* result = [outlineView makeViewWithIdentifier:@"OpenTabRowView" owner:self];
        Webpage_ w = std::static_pointer_cast<Webpage>([(CppSharedData*)item ptr]);
        result.webpage = w;
        result.data_item = item;
        result.outline = outlineView;
        result.line1 = w->title().toNSString();
        result.hovered = NO;
        return result;
    }
    if ([outlineView parentForItem:item] == self.search_results)
    {
        SearchResultCellView* result = [outlineView makeViewWithIdentifier:@"SearchResultsRowView" owner:self];
        Webpage_ w = std::static_pointer_cast<Webpage>([(CppSharedData*)item ptr]);
        result.line1 = w->title().toNSString();
        result.line2 = w->title_2().toNSString();
        result.line3 = w->title_3().toNSString();
        result.webpage = w;
        return result;
    }
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView
     heightOfRowByItem:(id)item
{
    if (item == self.open_tabs || item == self.search_results)
    {
        return 20;
    }
    if ([outlineView parentForItem:item] == self.open_tabs)
    {
        return 30;
    }
    if ([outlineView parentForItem:item] == self.search_results)
    {
        return 60;
    }
    return 0;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return 2;
    }
    if (item == self.open_tabs) {
        return self.open_tabs.get.count;
    }
    if (item == self.search_results) {
        return self.search_results.get.count;
    }
    return 0;
}


- (BOOL) isHeader:(id)item
{
    if (item == nil) {
        return YES;
    }
    if (item == self.open_tabs) {
        return YES;
    }
    if (item == self.search_results) {
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
    return [self isHeader:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(id)item
{
    return ! [self isHeader:item];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (IBAction)searchTab:(id)sender
{
    Global::controller->searchTabsAsync(QString::fromNSString(m_searchfield.stringValue));
}

- (IBAction)doubleClicked:(id)sender
{
    NSInteger index = [self.outline clickedRow] - Global::controller->open_tabs()->count() - 2; // -2 for labels
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
    NSInteger index = row_to_select - Global::controller->open_tabs()->count() - 2; // -2 for labels
    if (index >= 0 && index < Global::searchDB->search_result()->count()) {
        // clicked on search result
        Webpage_ p = Global::searchDB->search_result()->webpage_(static_cast<int>(index));
        Global::controller->newTabAsync(Controller::TabStatePreview,
                                        p->url(),
                                        Controller::WhenCreatedViewNew,
                                        Controller::WhenExistsViewExisting);
        return;
    }
    index = row_to_select - 1; // -1 for label
    if (index >= 0 && index < Global::controller->open_tabs()->count()) {
        // clicked on open tab
        Global::controller->viewTabAsync(Controller::TabStateOpen, static_cast<int>(index), (__bridge void*)self);
        return;
    }
}

- (BOOL)selectionShouldChangeInOutlineView:(NSOutlineView *)outlineView
{
    if (Global::controller->current_tab_state() == Controller::TabStateOpen)
    {
        return (outlineView.selectedRow == Global::controller->current_open_tab_index() + 1);
    }
    return YES;
}


- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView
               pasteboardWriterForItem:(id)item
{
    NSPasteboardItem* boarditem = [[NSPasteboardItem alloc] init];
    Webpage_ webpage = std::static_pointer_cast<Webpage>([(CppSharedData*)item ptr]);
    NSString* urlstr = webpage->url().full().toNSString();
    [boarditem setString:urlstr forType:NSPasteboardTypeURL];
    return boarditem;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
         acceptDrop:(id<NSDraggingInfo>)info
               item:(id)parent
         childIndex:(NSInteger)new_index
{
    NSPasteboard* pasteboard = info.draggingPasteboard;
    NSPasteboardItem* boarditem = pasteboard.pasteboardItems[0];
    NSString* urlstr = [boarditem stringForType:NSPasteboardTypeURL];
    
    int old_index = Global::controller->open_tabs()->findTab(QString::fromNSString(urlstr));
    if (old_index >= 0)
    {
        Global::controller->moveTabAsync(Controller::TabStateOpen, old_index, Controller::TabStateOpen, new_index, (__bridge void*)self);
    } else {
        Global::controller->newTabAsync(new_index, Controller::TabStateOpen, QString::fromNSString(urlstr), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
    }
    return YES;
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView
                  validateDrop:(id<NSDraggingInfo>)info
                  proposedItem:(id)parent
            proposedChildIndex:(NSInteger)index
{
    if (parent == self.open_tabs) {
        if (index < 0) {
            [outlineView setDropItem:parent dropChildIndex:0];
        }
        if (info.draggingSource == outlineView) {
            return NSDragOperationMove;
        }
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (void)outlineView:(NSOutlineView *)outlineView
    draggingSession:(NSDraggingSession *)session
   willBeginAtPoint:(NSPoint)screenPoint
           forItems:(NSArray *)draggedItems
{
    outlineView.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyleGap;
}

@end

@implementation MutableArrayWrapper : NSObject
@synthesize get = m_get;
- (instancetype)initWithArray:(NSMutableArray*)array
{
    self = [super init];
    self->m_get = array;
    return self;
}

+ (instancetype)wrap:(NSMutableArray*)array
{
    return [[MutableArrayWrapper alloc] initWithArray:array];
}
@end

