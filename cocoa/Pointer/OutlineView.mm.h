//
//  OutlineView.h
//  Pointer
//
//  Created by Yu Li on 2018-08-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/tabsmodel.hpp>
#include "CppData.mm.h"

@class OutlineViewDelegateAndDataSource;

@interface OpenTabCellView : NSTableCellView
{
    NSString* m_line1;
    BOOL m_hovered;
    NSTrackingArea* m_tracking_area;
    NSOutlineView* m_outline;
    CppData* m_data_item;
    Webpage_ m_webpage;
}
@property NSString* line1;
@property BOOL hovered;
@property NSOutlineView* outline;
@property CppData* data_item;
@property NSTrackingArea* tracking_area;
@property Webpage_ webpage;
- (IBAction)closeTab:(id)sender;
@end
//
//@interface CloseButton : NSButton
//{
//    IBOutlet OpenTab* m_open_tab;
//}
//@end

@interface SearchResultCellView : NSTableCellView
{
    NSString* m_line1;
    NSString* m_line2;
    NSString* m_line3;
    Webpage_ m_webpage;
}
@property NSString* line1;
@property NSString* line2;
@property NSString* line3;
@property Webpage_ webpage;
@end

typedef enum {
    OpenTabsListType,
    SearchResultsListType
} TabsListType;

@interface TabsList : NSObject
{
    TabsListType m_type;
    NSString* m_label;
    CppData* m_tabs;
}

@property TabsListType type;
@property NSString* label;
@property CppData* tabs;

- (TabsList*) initType:(TabsListType)type label:(NSString*)label;
@end

@interface MutableArrayWrapper : NSObject
{
    NSMutableArray* m_get;
}
@property (readonly) NSMutableArray* get;
- (instancetype)initWithArray:(NSMutableArray*)array;
+ (instancetype)wrap:(NSMutableArray*)array;
@end


@interface OutlineViewDelegateAndDataSource : NSObject<NSOutlineViewDataSource, NSOutlineViewDelegate>
{
//    TabsModel_ m_openTabsList;
//    TabsModel_ m_searchTabsList;
    IBOutlet NSOutlineView* m_outline;
    IBOutlet NSTextField* m_searchfield;
    OpenTabCellView* m_currently_hovered_opentab_cellview;
    MutableArrayWrapper* m_open_tabs;
    MutableArrayWrapper* m_search_results;
}

@property OpenTabCellView* currently_hovered_opentab_cellview;
@property NSOutlineView* outline;
@property (readonly) MutableArrayWrapper* open_tabs;
@property (readonly) MutableArrayWrapper* search_results;

- (IBAction)searchTab:(id)sender;
- (void)reloadAll;
- (void)reloadIndex:(id)item;
- (IBAction)doubleClicked:(id)sender;
- (void)updateSelection;
@end

