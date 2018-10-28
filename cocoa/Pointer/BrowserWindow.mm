//
//  BrowserWindow.m
//  Pointer
//
//  Created by Yu Li on 2018-07-31.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "BrowserWindow.mm.h"
#import "Extension/PTextView.h"
#import "Extension/PMenu.h"
#include <QtCore/QObject>
#include <docviewer/docviewer.h>
#include "OutlineView.mm.h"
#import "KeyCode.h"

@interface BrowserWindowController ()

@end

@implementation BrowserWindowController

@synthesize outlineview = m_outlineview;
@synthesize text_find_toolbar = m_text_find_toolbar;
@synthesize text_find_searchfield = m_text_find_searchfield;
@synthesize text_find_done_button = m_text_find_done_button;
@synthesize text_find_next_button = m_text_find_next_button;
@synthesize text_find_prev_button = m_text_find_prev_button;
@synthesize text_find_label = m_text_find_label;
@synthesize tab_searchfield = m_tab_searchfield;
@synthesize addressbar = m_addressbar;
@synthesize newtab_button = m_newtab_button;
@synthesize crawler_rules_popover = m_crawler_rules_popover;
@synthesize bookmarks_viewcontroller = m_bookmarks_viewcontroller;
//@synthesize tabview = m_tabview;

- (NSNibName) windowNibName {
    return @"BrowserWindow";
}

- (void)mouseUp:(NSEvent *)event {
    // zoom on click title bar
    if (event.clickCount == 2 && event.locationInWindow.y > self.window.frame.size.height - 20) {
        [self.window zoom:self];
    }
    [super mouseUp:event];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [self.outlineview expandItem:nil expandChildren:YES];
    [(OutlineViewDelegateAndDataSource*)self.outlineview.delegate updateSelection];
    [self.outlineview registerForDraggedTypes:@[NSPasteboardTypeURL]];
    self.text_find_toolbar.hidden = YES;
    
    QObject::connect(Global::controller,
                     &Controller::current_webpage_find_text_state_changed,
                     [=]()
    {
        [self performSelectorOnMainThread:@selector(handleNewTextFindState) withObject:nil waitUntilDone:YES];
    });
    QObject::connect(Global::controller,
                     &Controller::crawler_rule_table_enabled_changed,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handle_crawler_rule_table_enabled_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::bookmark_page_visible_changed,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handle_bookmarkpage_visible_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::downloads_visible_changed,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handle_downloads_visible_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_can_go_back_changed,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handle_can_go_buttons_enable_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_can_go_forward_changed,
                     [=]()
                     {
                         [self performSelectorOnMainThread:@selector(handle_can_go_buttons_enable_changed) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller, &Controller::current_tab_webpage_changed, [=]() {
        [self performSelectorOnMainThread:@selector(handle_current_tab_webpage_changed) withObject:nil waitUntilDone:YES];
    });
    [self handle_bookmarkpage_visible_changed];
    [self handle_can_go_buttons_enable_changed];
    [self handle_downloads_visible_changed];
    [self handle_crawler_rule_table_enabled_changed];
}

- (void)handle_current_tab_webpage_changed
{
    if (Global::controller->current_tab_webpage_is_blank())
    {
        [self.addressbar getFocus];
        self.addressbar.stringValue = @"";
    } else {
        [self.addressbar loseFocus];
    }
}
- (void)handle_bookmarkpage_visible_changed
{
    bool visible = Global::controller->bookmark_page_visible();
    self->m_bookmarks.hidden = ! visible;
    self->m_tabview.hidden = visible;
}

- (void)handle_can_go_buttons_enable_changed
{
    self->m_go_back_button.enabled = Global::controller->current_tab_webpage_can_go_back();
    self->m_go_forward_button.enabled = Global::controller->current_tab_webpage_can_go_forward();
}

- (void)handle_crawler_rule_table_enabled_changed
{
    if (Global::controller->crawler_rule_table_enabled()) {
        self->m_crawler_rule_table_button.enabled = YES;
    } else {
        self->m_crawler_rule_table_button.enabled = NO;
    }
}

- (void)handleNewTextFindState
{
    FindTextState state = Global::controller->current_webpage_find_text_state();
    if (state.visiable) {
        self.text_find_toolbar.hidden = NO;
        [self.window makeFirstResponder:self.text_find_searchfield];
    } else {
        self.text_find_toolbar.hidden = YES;
    }
    self.text_find_searchfield.stringValue = state.text.toNSString();
    self.text_find_label.hidden = (state.found == -1);
    if (state.found > 0) {
        self.text_find_label.stringValue = [NSString stringWithFormat:@"Found %d matches",state.found];
    } else {
        self.text_find_label.stringValue = @"Found 0 match";
    }
}

- (IBAction)handleFindTextDoneButtonClicked:(id)sender
{
    Global::controller->currentTabWebpageFindTextHideAsync();
}

- (IBAction)handleFindTextNextButtonClicked:(id)sender
{
    QString t = QString::fromNSString(self.text_find_searchfield.stringValue);
    Global::controller->currentTabWebpageFindTextNextAsync(t);
}

- (IBAction)handleCrawlerRuleButtonClicked:(id)sender
{
    [self.window makeFirstResponder:nil];
    Global::controller->set_crawler_rule_table_visible_async(true);
}

- (IBAction)handleDownloadsButtonClicked:(id)sender
{
    [self.window makeFirstResponder:nil];
    Global::controller->set_downloads_visible_async(true);
}

- (IBAction)handleFindTextPrevButtonClicked:(id)sender
{
    QString t = QString::fromNSString(self.text_find_searchfield.stringValue);
    Global::controller->currentTabWebpageFindTextPrevAsync(t);
}


- (void)handle_downloads_visible_changed
{
    if (Global::controller->downloads_visible()) {
        [self->m_downloads_popover showRelativeToRect:[self->m_downloads_button bounds]
                                               ofView:self->m_downloads_button
                                        preferredEdge:NSRectEdgeMaxY];
    } else {
        [self->m_downloads_popover close];
    }
}


- (IBAction)handleNewTabButtonClicked:(id)sender
{
    Global::controller->newTabAsync();
}

- (void)menuFocusAddress:(id)sender
{
    [self.addressbar getFocus];
}

- (void)menuFocusFindSymbol:(id)sender
{
    [self.window makeFirstResponder:self.tab_searchfield];
}

- (void)menuRefreshTab:(id)sender
{
    [self.addressbar.surface.refresh_button handleClicked];
}

- (void)menuNewTab:(id)sender
{
    [self.newtab_button performClick:self];
}
@end

@implementation NSResponder(Pointer)
- (void)menuFocusFindText:(id)sender
{
    Global::controller->currentTabWebpageFindTextShowAsync();
}

- (void)menuCloseTab:(id)sender
{
    Global::controller->closeTabAsync();
}

- (void)menuAddBookmark:(id)sender
{
    Global::controller->currentTabWebpageBookmarkAsync();
}

- (void)menuShowNextTab:(id)sender
{
    Global::controller->showNextOpenTabAsync();
}

- (void)menuShowPrevTab:(id)sender
{
    Global::controller->showPrevOpenTabAsync();
}

- (void)menuEditBookmarks:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:FileManager::bookmarksPath().toNSString()];
}

- (void)menuEditCrawlerRules:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:FileManager::crawlerRulesPath().toNSString()];
}
@end

@implementation BrowserWindow

- (id)validRequestorForSendType:(NSPasteboardType)sendType
                     returnType:(NSPasteboardType)returnType
{
    return nil;
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if (event.keyCode == kVK_Escape)
    {
        if (Global::controller->current_webpage_find_text_state().visiable) {
            BrowserWindowController* ctl = self.windowController;
            [ctl.text_find_done_button performClick:self];
            return YES;
        }
        [self makeFirstResponder:self.windowController];
        return YES;
    }
    if (event.keyCode == kVK_Tab &&
        (event.modifierFlags & NSEventModifierFlagControl))
    {
        [self makeFirstResponder:[(BrowserWindowController*)self.windowController outlineview]];
    }
    return [super performKeyEquivalent:event];
}
//
//- (PTextView *)fieldEditor:(BOOL)createFlag
//              forObject:(id)object
//{
//    NSText* text = [super fieldEditor:createFlag forObject:object];
//    if (text) {
//        static PTextView* ptextview = [[PTextView alloc] initWithNSText:text];
//    //    ptextview.delegate = text.delegate;
//    //    static PMenuDelegate* delegate = [[PMenuDelegate alloc] init];
//    //    text.menu = [[PMenu alloc] init];
//    //    text.menu.delegate = delegate;
//
//        return ptextview;
//    }
//    return nil;
//}
@end


@implementation BrowserWindowDelegate

- (instancetype)init
{
    self = [super init];
    self->m_general_ptextview = [[PTextView alloc] init];
    self->m_general_textviewdelegate = [[GeneralTextViewDelegate alloc] init];
    self->m_general_ptextview.delegate = self->m_general_textviewdelegate;
    return self;
}
//
- (id)windowWillReturnFieldEditor:(NSWindow *)sender
                         toObject:(id)client
{
    static PTextView* ptextview = [[PTextView alloc] init];
    return ptextview;
}

@end

@implementation GeneralTextViewDelegate
@end

@implementation BrowserWindowView
//
//- (BOOL)performKeyEquivalent:(NSEvent *)event
//{
//    if (event.keyCode == kVK_Escape)
//    {
//        [self.window makeFirstResponder:self];
//        if (Global::controller->current_webpage_find_text_state().visiable) {
//            Global::controller->currentTabWebpageFindTextHideAsync();
//        }
//        return YES;
//    }
//    return [super performKeyEquivalent:event];
//}

@end


@implementation DownloadPopoverDelegate
- (void)popoverWillShow:(NSNotification *)notification
{
    int nrows = Global::controller->download_files()->count();
    NSSize size = self->m_download_popover.contentSize;
    size.height = MIN(53 * nrows + 60, 500);
    self->m_download_popover.contentSize = size;
}
@end
