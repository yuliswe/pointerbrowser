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

@interface BrowserWindowController : NSWindowController
{
    IBOutlet NSOutlineView* m_outlineview;
    IBOutlet NSSearchField* m_tab_searchfield;
    IBOutlet AddressBar* m_addressbar;
    IBOutlet NSButton* m_crawler_rules_popover_button;
    IBOutlet NSBox* m_text_find_toolbar;
    IBOutlet NSSearchField* m_text_find_searchfield;
    IBOutlet NSButton* m_text_find_done_button;
    IBOutlet NSButton* m_text_find_next_button;
    IBOutlet NSButton* m_text_find_prev_button;
    IBOutlet NSTextField* m_text_find_label;
    IBOutlet NSButton* m_newtab_button;
    IBOutlet CrawlerRulesPopover* m_crawler_rules_popover;
    IBOutlet NSButton* m_crawler_rule_table_button;
}

@property NSOutlineView* outlineview;
@property NSBox* text_find_toolbar;
@property NSSearchField* text_find_searchfield;
@property NSSearchField* tab_searchfield;
@property AddressBar* addressbar;
@property NSButton* newtab_button;
@property NSButton* text_find_done_button;
@property NSButton* text_find_next_button;
@property NSButton* text_find_prev_button;
@property NSTextField* text_find_label;
@property CrawlerRulesPopover* crawler_rules_popover;
@end

@interface BrowserWindow : NSWindow

@end


@interface BrowserWindowView : NSView

@end
