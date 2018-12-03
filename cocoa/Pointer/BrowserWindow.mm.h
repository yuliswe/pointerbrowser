//
//  BrowserWindow.h
//  Pointer
//
//  Created by Yu Li on 2018-07-31.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "WebUI.mm.h"
#import "CrawlerRulesPopover.mm.h"
#import "Bookmarks.mm.h"
#import "Extension/PTextView.h"
#import "Downloads.h"
#import "ErrorPage.h"
#import "AddTagsPopover.h"
#import "OutlineView.mm.h"

@interface NSResponder(Pointer)
- (IBAction)menuNewTab:(id)sender;
- (IBAction)menuCloseTab:(id)sender;
- (IBAction)menuRefreshTab:(id)sender;
- (IBAction)menuFocusFindText:(id)sender;
- (IBAction)menuFocusFindSymbol:(id)sender;
- (IBAction)menuFocusAddress:(id)sender;
- (IBAction)menuAddBookmark:(id)sender;
- (IBAction)menuShowNextTab:(id)sender;
- (IBAction)menuShowPrevTab:(id)sender;
- (IBAction)menuEditBookmarksAsJsonFile:(id)sender;
- (IBAction)menuEditCrawlerRules:(id)sender;
- (IBAction)menuShowEULA:(id)sender;
- (IBAction)menuAddTagsForCurrentTab:(id)sender;
- (IBAction)menuEditTagsAsJsonFile:(id)sender;
- (IBAction)menuKeepCurrentTabOpen:(id)sender;
+ (void)inspectResponderChain;
@end


@interface BrowserWindowController : NSWindowController
@property IBOutlet OutlineViewController* outlineViewController;
@property IBOutlet NSBox* text_find_toolbar;
@property IBOutlet NSSearchField* text_find_searchfield;
@property IBOutlet NSSearchField* tab_searchfield;
@property IBOutlet AddressBar* addressbar;
@property IBOutlet NSButton* newtab_button;
@property IBOutlet NSButton* text_find_done_button;
@property IBOutlet NSButton* text_find_next_button;
@property IBOutlet NSButton* text_find_prev_button;
@property IBOutlet NSTextField* text_find_label;
@property IBOutlet NSButton* go_back_button;
@property IBOutlet NSButton* go_forward_button;
@property IBOutlet NSButton* downloads_button;
@property IBOutlet NSPopover* downloads_popover;
@property IBOutlet DownloadsViewController* download_viewcontroller;
@property IBOutlet CrawlerRulesPopover* crawler_rules_popover;
@property IBOutlet NSButton* crawler_rule_table_button;
@property IBOutlet BookmarksViewController* bookmarks_viewcontroller;
@property IBOutlet NSView* bookmarks_view_container;
@property IBOutlet NSView* tab_view_container;
@property IBOutlet NSView* left_wrapper;
@property IBOutlet NSView* right_wrapper;
@property IBOutlet NSSplitView* splitView;
@property IBOutlet NSView* splitViewLeftPanel;
@property IBOutlet NSView* splitViewRightPanel;
@property IBOutlet NSView* splitViewLeftPanelToolBar;
@property IBOutlet NSView* splitViewRightPanelToolBar;
@property IBOutlet NSView* splitViewRightPanelContent;
@property IBOutlet NSView* splitViewRightPanelContentFullscreenWrapper;
@property BOOL fullscreenMode;
- (void)enterFullscreenMode;
- (void)exitFullscreenMode;
@end

@interface GeneralTextViewDelegate : NSObject<NSTextViewDelegate>
@end

@interface BrowserWindow : NSWindow
@end

@interface BrowserWindowDelegate : NSObject<NSWindowDelegate>
@end

@interface BrowserWindowView : NSView
@end


@interface DownloadPopoverDelegate : NSObject<NSPopoverDelegate>
{
    IBOutlet DownloadsViewController* m_download_popover_viewcontroller;
    IBOutlet NSPopover* m_download_popover;
}
@end
