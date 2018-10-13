//
//  OutlineView.m
//  Pointer
//
//  Created by Yu Li on 2018-08-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "OutlineView.mm.h"
#import "CppData.mm.h"
#include <docviewer/webpage.hpp>
#include <docviewer/global.hpp>
#include <Carbon/Carbon.h>

@implementation SearchField
//- (BOOL)performKeyEquivalent:(NSEvent *)event
//{
//    if ((event.modifierFlags & NSEventModifierFlagCommand)
//        && (event.keyCode == kVK_ANSI_D))
//    {
//        [self.window makeFirstResponder:self];
//        return YES;
//    }
//    return NO;
//}
@end

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

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:@"currently_hovered_opentab_cellview"])
//    {
//        OutlineViewDelegateAndDataSource* delegate = (OutlineViewDelegateAndDataSource*)self.outline.delegate;
//        self.hovered = (delegate.currently_hovered_opentab_cellview == self);
//    }
//}

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

//- (instancetype)initWithCoder:(NSCoder*)coder
//{
//    self = [super initWithCoder:coder];
//    return self;
//}
//
//- (void)setOutline:(NSOutlineView *)outline
//{
//    self.outline = outline;
//}

- (OutlineViewDelegateAndDataSource*)init
{
    self = [super init];
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsInserted,
                     [=]()
    {
        [self performSelectorOnMainThread:@selector(reloadAll) withObject:nil waitUntilDone:YES];
    });

    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::rowsRemoved,
                     [=]()
    {
        [self performSelectorOnMainThread:@selector(reloadAll) withObject:nil waitUntilDone:YES];
    });
 
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::rowsInserted,
                     [=] (const QModelIndex &parent, int first, int last)
    {
        [self performSelectorOnMainThread:@selector(reloadAll) withObject:nil waitUntilDone:YES];
    });
    
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last)
    {
        [self performSelectorOnMainThread:@selector(reloadAll) withObject:nil waitUntilDone:YES];
    });
    
    QObject::connect(Global::controller->open_tabs().get(), &TabsModel::dataChanged,
                     [=](const QModelIndex &topLeft, const QModelIndex &bottomRight)
    {
        if (topLeft == bottomRight) {
            int idx = topLeft.row() + 1; // +1 for label
            [self performSelectorOnMainThread:@selector(reloadIndex:) withObject:[NSNumber numberWithInt:idx] waitUntilDone:YES];
        }
    });
    
    QObject::connect(Global::searchDB->search_result().get(), &TabsModel::dataChanged,
                     [=](const QModelIndex &topLeft, const QModelIndex &bottomRight)
     {
         if (topLeft == bottomRight) {
             int idx = topLeft.row() + Global::controller->open_tabs()->count() + 2; // +2 for labels
             [self performSelectorOnMainThread:@selector(reloadIndex:) withObject:[NSNumber numberWithInt:idx] waitUntilDone:YES];
         }
     });
    
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_changed,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(updateSelection) withObject:nil waitUntilDone:YES];
                     });
    
//    [self reloadAll];
}

- (void)updateSelection
{
    if (Global::controller->current_tab_state() == Controller::TabStateEmpty) {
        NSIndexSet *indexSet = [NSIndexSet indexSet];
        [self.outline selectRowIndexes:indexSet byExtendingSelection:NO];
        return;
    }
    int i = Global::controller->current_open_tab_highlight_index();
    if (i >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(i + 1)]; // +1 for label
        [self.outline selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    int j = Global::controller->current_tab_search_highlight_index();
    int offset = Global::controller->open_tabs()->count();
    if (j >= 0) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:(j + offset + 2)]; // +2 for label
        [self.outline selectRowIndexes:indexSet byExtendingSelection:NO];
    }
}

// called when the search result changed
- (void)reloadAll
{
    [self.outline reloadItem:nil reloadChildren:YES];
    [self.outline expandItem:nil expandChildren:YES];
    [self updateSelection];
}

// called when a tab's title is updated
- (void)reloadIndex:(NSNumber*)index
{
    int idx = index.intValue;
    id item = [self.outline itemAtRow:idx];
    [self.outline reloadItem:item reloadChildren:YES];
    [self updateSelection];
}

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    int idx = static_cast<int>(index);
    if (item == nil) {
        if (index == 0) {
            return [CppSharedData wrap:(Global::controller->open_tabs())];
        }
        if (index == 1) {
            return [CppSharedData wrap:(Global::searchDB->search_result())];
        }
    }
    TabsModel_ ptr = std::static_pointer_cast<TabsModel>([(CppSharedData*)item ptr]);
    if (ptr == Global::controller->open_tabs()) {
        return [CppSharedData wrap:Global::controller->open_tabs()->webpage_(idx)];
    }
    if (ptr == Global::searchDB->search_result()) {
        return [CppSharedData wrap:Global::searchDB->search_result()->webpage_(idx)];
    }
    return nil;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView
     viewForTableColumn:(NSTableColumn *)tableColumn
                   item:(id)item
{
    // For the groups, we just return a regular text view.
    if ([(CppSharedData*)item ptr] == Global::controller->open_tabs()) {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Open Tabs";
        return result;
    }
    if ([(CppSharedData*)item ptr] == Global::searchDB->search_result()) {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"HeaderRowView" owner:self];
        result.objectValue = @"Discoveries";
        return result;
    }
    if ([(CppSharedData*)[outlineView parentForItem:item] ptr] == Global::controller->open_tabs()) {
        OpenTabCellView* result = [outlineView makeViewWithIdentifier:@"OpenTabRowView" owner:self];
        Webpage_ w = std::static_pointer_cast<Webpage>([(CppSharedData*)item ptr]);
        result.webpage = w;
        result.data_item = item;
        result.outline = outlineView;
        result.line1 = w->title().toNSString();
        result.hovered = NO;
//        [self addObserver:result forKeyPath:@"currently_hovered_opentab_cellview" options:NSKeyValueObservingOptionNew context:nil];
        return result;
    }
    if ([(CppSharedData*)[outlineView parentForItem:item] ptr] == Global::searchDB->search_result()) {
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
    if ([(CppSharedData*)item ptr] == Global::controller->open_tabs()
        || [(CppSharedData*)item ptr] == Global::searchDB->search_result()) {
        return 20;
    }
    if ([(CppSharedData*)[outlineView parentForItem:item] ptr] == Global::controller->open_tabs()) {
        return 30;
    }
    if ([(CppSharedData*)[outlineView parentForItem:item] ptr] == Global::searchDB->search_result()) {
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
    if ([(CppSharedData*)item ptr] == Global::controller->open_tabs()) {
        return Global::controller->open_tabs()->count();
    }
    if ([(CppSharedData*)item ptr] == Global::searchDB->search_result()) {
        return Global::searchDB->search_result()->count();
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    if (item == nil) {
        return YES;
    }
    if ([(CppSharedData*)item ptr] == Global::controller->open_tabs()) {
        return YES;
    }
    if ([(CppSharedData*)item ptr] == Global::searchDB->search_result()) {
        return YES;
    }
    return NO;
}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView
//   shouldExpandItem:(id)item
//{
//    return [self outlineView:outlineView isItemExpandable:item];
//}

- (BOOL)outlineView:(NSOutlineView *)outlineView
shouldShowOutlineCellForItem:(id)item
{
    return NO;
}

- (IBAction)searchTab:(id)sender
{
    Global::controller->searchTabsAsync(QString::fromNSString(m_searchfield.stringValue));
}
//
//- (IBAction)clicked:(id)sender
//{
//
//    NSInteger index = [self.outline clickedRow] - Global::controller->open_tabs()->count() - 2; // -2 for labels
//    if (index >= 0 && index < Global::searchDB->search_result()->count()) {
//        // clicked on search result
//        Webpage* p = Global::searchDB->search_result()->webpage(static_cast<int>(index));
//        Global::controller->newTabAsync(Controller::TabStatePreview,
//                                                  p->url(),
//                                                  Controller::WhenCreatedViewNew,
//                                                  Controller::WhenExistsViewExisting);
//        return;
//    }
//
//    index = [self.outline clickedRow] - 1; // -1 for label
//    if (index >= 0 && index < Global::controller->open_tabs()->count()) {
//        // clicked on open tab
//        Global::controller->viewTabAsync(Controller::TabStateOpen, static_cast<int>(index));
//        return;
//    }
//
//}

- (IBAction)doubleClicked:(id)sender
{
    NSInteger index = [self.outline clickedRow] - Global::controller->open_tabs()->count() - 2; // -2 for labels
    if (index >= 0) {
        // clicked on search result
        Webpage* p = Global::searchDB->search_result()->webpage(static_cast<int>(index));
        Global::controller->newTabAsync(Controller::TabStateOpen,
                                                  p->url(),
                                                  Controller::WhenCreatedViewNew,
                                                  Controller::WhenExistsViewExisting);
    }
}
//
//- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
//{
//    return [self.outline parentForItem:item] != nil;
//}

- (BOOL)outlineView:(NSOutlineView *)outlineView
   shouldSelectItem:(id)item
{
    NSInteger row_to_select = [outlineView rowForItem:item];
    NSInteger index = row_to_select - Global::controller->open_tabs()->count() - 2; // -2 for labels
    if (index >= 0 && index < Global::searchDB->search_result()->count()) {
        // clicked on search result
        Webpage* p = Global::searchDB->search_result()->webpage(static_cast<int>(index));
        Global::controller->newTabAsync(Controller::TabStatePreview,
                                        p->url(),
                                        Controller::WhenCreatedViewNew,
                                        Controller::WhenExistsViewExisting);
        return YES;
    }
    index = row_to_select - 1; // -1 for label
    if (index >= 0 && index < Global::controller->open_tabs()->count()) {
        // clicked on open tab
        Global::controller->viewTabAsync(Controller::TabStateOpen, static_cast<int>(index));
        return YES;
    }
    return [outlineView parentForItem:item] != nil;
}
@end
