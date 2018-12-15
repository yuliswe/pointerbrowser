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
    [self.outlineViewController loadView];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    self.text_find_toolbar.hidden = YES;
    self.fullscreenMode = NO;
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
    QObject::connect(Global::controller,
                     &Controller::current_tab_search_word_changed,
                     [=](QString const& val, void const* sender)
                     {
                         if (sender == (__bridge void*)self.tab_searchfield) { return; }
                         [self performSelectorOnMainThread:@selector(handle_current_tab_search_word_changed) withObject:nil waitUntilDone:YES];
                     });
//    QObject::connect(Global::controller,
//                     &Controller::current_tab_webpage_is_error_changed,
//                     [=]()
//                     {
//                         [self performSelectorOnMainThread:@selector(handle_current_tab_webpage_is_error_changed) withObject:nil waitUntilDone:YES];
//                     });
//    QObject::connect(Global::controller, &Controller::current_tab_webpage_changed, [=]() {
//        [self performSelectorOnMainThread:@selector(handle_current_tab_webpage_changed) withObject:nil waitUntilDone:YES];
//    });
    [self handle_bookmarkpage_visible_changed];
    [self handle_can_go_buttons_enable_changed];
    [self handle_downloads_visible_changed];
    [self handle_crawler_rule_table_enabled_changed];
    [self handle_current_tab_webpage_is_error_changed];
}

- (void)handle_current_tab_webpage_is_error_changed
{
    if (Global::controller->current_tab_webpage_is_error())
    {
    } else {
    }
}

- (void)handle_current_tab_search_word_changed
{
    self.tab_searchfield.stringValue = Global::controller->current_tab_search_word().toNSString();
}
//- (void)handle_current_tab_webpage_changed
//{
//    if (Global::controller->current_tab_webpage_is_blank())
//    {
//        [self.addressbar getFocus];
//        self.addressbar.stringValue = @"";
//    } else {
//        [self.addressbar loseFocus];
//    }
//}
- (void)handle_bookmarkpage_visible_changed
{
    bool visible = Global::controller->bookmark_page_visible();
//    [NSResponder inspectResponderChain];
    if (visible) {
        [self.window makeFirstResponder:self.addressbar];
        self.addressbar.stringValue = @"";
    } else {
        [self.window makeFirstResponder:self.outlineViewController.outlineView];
    }
    self.bookmarks_view_container.hidden = ! visible;
    self.tab_view_container.hidden = visible;
}

- (void)handle_can_go_buttons_enable_changed
{
    self.go_back_button.enabled = Global::controller->current_tab_webpage_can_go_back();
    self.go_forward_button.enabled = Global::controller->current_tab_webpage_can_go_forward();
}

- (void)handle_crawler_rule_table_enabled_changed
{
    if (Global::controller->crawler_rule_table_enabled()) {
        self.crawler_rule_table_button.enabled = YES;
    } else {
        self.crawler_rule_table_button.enabled = NO;
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
        [self.downloads_popover showRelativeToRect:[self.downloads_button bounds]
                                               ofView:self.downloads_button
                                        preferredEdge:NSRectEdgeMaxY];
    } else {
        [self.downloads_popover close];
    }
}


- (IBAction)handleNewTabButtonClicked:(id)sender
{
    Global::controller->newTabAsync();
}

- (IBAction)menuFocusAddress:(id)sender
{
    [self.addressbar getFocus];
}

- (IBAction)menuFocusFindSymbol:(id)sender
{
    [self.window makeFirstResponder:self.tab_searchfield];
}

- (IBAction)menuRefreshTab:(id)sender
{
    [self.addressbar.surface.refresh_button handleClicked];
}

- (IBAction)menuNewTab:(id)sender
{
    [self.newtab_button performClick:self];
}

- (IBAction)menuAddTagsForCurrentTab:(id)sender
{
    [self.outlineViewController showAddTagsPopoverForCurrentTab:nil];
}

- (IBAction)menuShowEULA:(id)sender
{
    Global::controller->newTabAsync(Controller::TabStateOpen, Url("about:eula"), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
}

- (IBAction)searchTab:(id)sender
{
    Global::controller->searchTabsAsync(QString::fromNSString(self.tab_searchfield.stringValue), (__bridge void*)self.tab_searchfield);
}

- (IBAction)menuKeepCurrentTabOpen:(id)sender
{
    Webpage_ w = Global::controller->current_tab_webpage();
    Global::controller->newTabAsync(Controller::TabStateOpen, w->url(), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
}

- (IBAction)menuPrint:(id)sender
{
    [self.tabViewController print];
}

- (IBAction)menuDownloadAsWebArchive:(id)sender
{
    [self.tabViewController downloadAsWebArchive];
}

- (IBAction)menuDownloadAsPDF:(id)sender
{
    [self.tabViewController downloadAsPDF];
}

- (void)enterFullscreenMode
{
    self.splitView.hidden = YES;
    [self.splitViewRightPanelContentFullscreenWrapper removeFromSuperviewWithoutNeedingDisplay];
    self.splitViewRightPanelContentFullscreenWrapper.frame = self.window.contentView.bounds;
    [self.window.contentView addSubview:self.splitViewRightPanelContentFullscreenWrapper];
    self.fullscreenMode = YES;
}

- (void)exitFullscreenMode
{
    self.splitView.hidden = NO;
    [self.splitViewRightPanelContentFullscreenWrapper removeFromSuperviewWithoutNeedingDisplay];
    self.splitViewRightPanelContentFullscreenWrapper.frame = self.splitViewRightPanelContent.bounds;
    [self.splitViewRightPanelContent addSubview:self.splitViewRightPanelContentFullscreenWrapper];
    self.fullscreenMode = NO;
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
    Global::controller->cycleNextTabAsync();
}

- (void)menuShowPrevTab:(id)sender
{
    Global::controller->cyclePrevTabAsync();
}

- (void)menuEditBookmarksAsJsonFile:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:FileManager::bookmarksPath().toNSString()];
}

- (void)menuEditTagsAsJsonFile:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:FileManager::dataPath("tags").toNSString()];
}

- (void)menuEditCrawlerRules:(id)sender
{
    [[NSWorkspace sharedWorkspace] openFile:FileManager::crawlerRulesPath().toNSString()];
}

- (IBAction)menuOpenInSafari:(id)sender
{
    Webpage_ w = Global::controller->current_tab_webpage();
    [[NSWorkspace sharedWorkspace] openURLs:[NSArray arrayWithObject:w->url().toNSURL()] withAppBundleIdentifier:@"com.apple.Safari" options:NSWorkspaceLaunchDefault additionalEventParamDescriptor:nil launchIdentifiers:nil];
}

- (IBAction)menuReloadBookmarksAndTags:(id)sender
{
    Global::controller->reloadBookmarksAsync();
    Global::controller->reloadAllTagsAsync();
}


+ (void)inspectResponderChain
{
    NSWindow *mainWindow = [NSApplication sharedApplication].mainWindow;
    NSMutableString* toprint = [[NSMutableString alloc] initWithString:@"Responder chain:"];
    NSResponder *responder = mainWindow.firstResponder;
    do {
        NSString* newpart = [NSString stringWithFormat:@" -> %@", responder];
        [toprint appendString:newpart];
    } while ((responder = [responder nextResponder]));
    NSLog(@"%@", toprint);
}
@end

@implementation BrowserWindow

- (id)validRequestorForSendType:(NSPasteboardType)sendType
                     returnType:(NSPasteboardType)returnType
{
    return nil;
}

- (NSResponder*)initialFirstResponder
{
    BrowserWindowController* controller = (BrowserWindowController*)self.windowController;
    return controller.outlineViewController.outlineView;
}

- (BOOL)makeFirstResponder:(NSResponder *)responder {
//    NSLog(@"make first responder: %@", responder);
//    [NSResponder inspectResponderChain];
    if (responder == nil) {
        BrowserWindowController* controller = (BrowserWindowController*)self.windowController;
        responder = controller.outlineViewController.outlineView;
    }
    BOOL rt = [super makeFirstResponder:responder];
    return rt;
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
    if (event.keyCode == kVK_Escape)
    {
        if (Global::controller->current_webpage_find_text_state().visiable) {
            BrowserWindowController* ctl = self.windowController;
            [ctl.text_find_done_button performClick:self];
            return YES;
        } else if (! Global::controller->current_tab_search_word().isEmpty()) {
            Global::controller->searchTabsAsync("");
        }
        [self makeFirstResponder:nil];
        return YES;
    }
    if (event.keyCode == kVK_Tab &&
        (event.modifierFlags & NSEventModifierFlagControl))
    {
        BrowserWindowController* windowController = self.windowController;
        [self makeFirstResponder:windowController.outlineViewController.outlineView];
    }
    return [super performKeyEquivalent:event];
}
@end


@implementation BrowserWindowDelegate
- (id)windowWillReturnFieldEditor:(NSWindow *)sender
                         toObject:(id)client
{
    static PTextView* ptextview = [[PTextView alloc] init];
    return ptextview;
}

- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    BrowserWindow* window = notification.object;
    BrowserWindowController* controller = window.windowController;
    {
        NSRect frame = controller.left_wrapper.frame;
        frame.size.height = window.frame.size.height + 1;
        controller.left_wrapper.frame = frame;
    }
    {
        NSRect frame = controller.right_wrapper.frame;
        frame.size.height = window.frame.size.height + 1;
        controller.right_wrapper.frame = frame;
    }
}

- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    BrowserWindow* window = notification.object;
    BrowserWindowController* controller = window.windowController;
    {
        NSRect frame = controller.left_wrapper.frame;
        frame.size.height = window.frame.size.height - 16;
        controller.left_wrapper.frame = frame;
    }
    {
        NSRect frame = controller.right_wrapper.frame;
        frame.size.height = window.frame.size.height - 16;
        controller.right_wrapper.frame = frame;
    }
    // if entered full screen video mode
    if (controller.fullscreenMode) {
        [controller exitFullscreenMode];
    }
}
@end

@implementation GeneralTextViewDelegate
@end

@implementation BrowserWindowView
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
