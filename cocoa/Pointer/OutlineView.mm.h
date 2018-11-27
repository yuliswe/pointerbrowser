//
//  OutlineView.h
//  Pointer
//
//  Created by Yu Li on 2018-08-05.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <docviewer/tabsmodel.hpp>
#include "CppData.h"
#import "Extension/PViewController.h"
#import "AddTagsPopover.h"

@class OutlineView;

@interface OpenTabItem : NSObject<WebpageWrapper,NSCoding,NSPasteboardWriting,NSPasteboardReading>
@property NSString* title;
@property Webpage_ webpage;
@property OutlineView* outlineView;
@end

@interface OpenGroupItem : NSObject
@property NSMutableArray<OpenTabItem*>* children;
@property OutlineView* outlineView;
@end

@interface SearchResultTabItem : NSObject<WebpageWrapper,NSPasteboardWriting,NSPasteboardReading>
@property NSString* line1;
@property NSString* line2;
@property NSString* line3;
@property Webpage_ webpage;
@property OutlineView* outlineView;
@end

@interface SearchResultGroupItem : NSObject
@property NSMutableArray<SearchResultTabItem*>* children;
@property OutlineView* outlineView;
@end

@interface WorkspaceTabItem : NSObject<WebpageWrapper,NSPasteboardWriting,NSPasteboardReading>
@property NSString* title;
@property TagContainer_ tagContainer;
@property Webpage_ webpage;
@property OutlineView* outlineView;
@end

@interface WorkspaceGroupItem : NSObject<TagContainerWrapper,NSPasteboardWriting,NSPasteboardReading>
@property NSString* title;
@property TagContainer_ tagContainer;
@property NSMutableArray<WorkspaceTabItem*>* children;
@property OutlineView* outlineView;
@end

@interface TrackingAreaCellView : NSTableCellView
@property BOOL hovered;
@property NSTrackingArea* tracking_area;
@property id item;
@property OutlineView* outlineView;
- (IBAction)closeTab:(id)sender;
@end

@interface WorkspaceHeaderCellView : TrackingAreaCellView
- (IBAction)unpin:(id)sender;
@end

@interface WorkspaceHeaderCellUnpinButton : NSButton
@property IBOutlet WorkspaceHeaderCellView* headerCellView;
@end

@interface WorkspaceTabItemMenu : NSMenu<WebpageWrapper>
@property Webpage_ webpage;
- (void)listRemoveTabOptionsForTagContainer:(TagContainer_)c webpage:(Webpage_)w;
@end

@interface OpenTabItemMenu : NSMenu<WebpageWrapper>
@property Webpage_ webpage;
@end

@interface SearchResultTabItemMenu : NSMenu<WebpageWrapper>
@property Webpage_ webpage;
@end

@interface RemoveTagMenuItem : NSMenuItem
@property TagContainer_ tagContainer;
@property Webpage_ webpage;
@end

@interface OutlineView : NSOutlineView<NSOutlineViewDataSource, NSOutlineViewDelegate>
@property IBOutlet OpenTabItemMenu* open_tab_menu;
@property IBOutlet WorkspaceTabItemMenu* workspace_tab_menu;
@property IBOutlet SearchResultTabItemMenu* search_result_tab_menu;
@property SearchResultGroupItem* search_result_group_item;
@property OpenGroupItem* open_group_item;
@property NSMutableArray<WorkspaceGroupItem*>* workspaces;

- (IBAction)searchTab:(id)sender;
- (void)reloadIndex:(id)item;
- (IBAction)doubleClicked:(id)sender;
- (void)handleIndexesChangesInController;
- (BOOL)isHeader:(id)item;
- (NSUInteger)workspacesOffset;
- (NSUInteger)openTabsOffset;
- (NSUInteger)searchResultsOffset;
@end

@interface OutlineViewController : PViewController
@property IBOutlet OutlineView* outlineView;
@property IBOutlet AddTagsPopover* add_tags_popover;
- (void)showAddTagsPopoverForCurrentTab:(id)sender;
@end
