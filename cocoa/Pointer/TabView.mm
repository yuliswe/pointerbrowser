//
//  TabView.m
//  Pointer
//
//  Created by Yu Li on 2018-08-11.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import "TabView.mm.h"
#import "WebUI.mm.h"
#import "AddressBar.mm.h"
#include <docviewer/controller.hpp>
#include <docviewer/tabsmodel.hpp>
#include <docviewer/global.hpp>
#include <QtCore/QObject>

@implementation TabViewItem

@synthesize webview = m_webview;
@synthesize webpage = m_webpage;
@synthesize tabview = m_tabview;

- (instancetype)initWithWebpage:(Webpage_)webpage
                        tabview:(TabView*)tabview
{
    self = [super init];
    self.webpage = webpage;
    self.webview = [[WebUI alloc] initWithWebpage:webpage frame:tabview.bounds config:nil];
    if (webpage->url().full() == "about:eula") {
        NSString* eula_path = [[NSBundle mainBundle] pathForResource:@"eula" ofType:@"html"];
        NSString* eula = [NSString stringWithContentsOfFile:eula_path encoding:NSUTF8StringEncoding error:nil];
        [self.webview loadHTMLString:eula baseURL:webpage->url().toNSURL()];
    } else {
        [self.webview loadUri:webpage->url().full().toNSString()];
    }
    self.view = self.webview;
    self.tabview = tabview;
    return self;
}

- (instancetype)initWithWebUI:(WebUI*)webui
                      webpage:(Webpage_)page
                      tabview:(TabView*)tabview
{
    self = [super init];
    self.webpage = page;
    self.webview = webui;
    self.view = self.webview;
    self.tabview = tabview;
    return self;
}

- (void)dealloc
{
    [self.webview stopLoading];
    [self.webview loadUri:@""];
    self.webpage->disconnect(); // it is important to release connection so WebUI can be freed by GC
}

@end

@implementation TabView

@synthesize address_bar = m_address_bar;

- (TabView*)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    self.hidden = YES;
    QObject::connect(Global::controller->open_tabs().get(),
                     &TabsModel::rowsInserted,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(onOpenTabRowsInserted:) withObject:args waitUntilDone:YES];
                     });
    
    QObject::connect(Global::controller->open_tabs().get(),
                     &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(onOpenTabRowsRemoved:) withObject:args waitUntilDone:YES];
                     });
    
    QObject::connect(Global::controller->open_tabs().get(),
                     &TabsModel::signal_tf_tab_moved,
                     [=](int from, int to) {
                         NSDictionary* args = @{@"from" : [NSNumber numberWithInt:from], @"to": [NSNumber numberWithInt:to]};
                         [self performSelectorOnMainThread:@selector(handleOpenTabsMoved:) withObject:args waitUntilDone:YES];
                     });
    
    QObject::connect(Global::controller->preview_tabs().get(),
                     &TabsModel::rowsInserted,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(onPreviewTabRowsInserted:) withObject:args waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->preview_tabs().get(),
                     &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(onPreviewTabRowsRemoved:) withObject:args waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->preview_tabs().get(),
                     &TabsModel::modelReset,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_preview_tab_model_reset) withObject:nil waitUntilDone:YES];
                     });
    [self reload];
    // selection changed signal should only be connected after view is for sure loaded
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_changed,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(updateSelection) withObject:nil waitUntilDone:YES];
                     });
    
    return self;
}

- (void)handleOpenTabsMoved:(NSDictionary*)indices
{
    int from = [indices[@"from"] intValue];
    int to = [indices[@"to"] intValue];
    NSTabViewItem* item = [self tabViewItemAtIndex:from];
    [self removeTabViewItem:item];
    [self insertTabViewItem:item atIndex:(from < to ? to - 1 : to)];
}

- (void)onPreviewTabRowsRemoved:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    int offset = Global::controller->open_tabs()->count();
    auto current = self.tabViewItems;
    for (int i = 0; i < count; i++) {
        NSTabViewItem* item = current[i+first+offset];
        [self removeTabViewItem:item];
//        [[(TabViewItem*)item webview] loadUri:@"about:blank"];
    }
}

- (void)handle_preview_tab_model_reset
{
    int offset = Global::controller->open_tabs()->count();
    auto current = self.tabViewItems;
    int count = self.tabViewItems.count;
    for (int i = offset; i < count; i++) {
        NSTabViewItem* item = current[i];
        [self removeTabViewItem:item];
    }
}

- (void)onPreviewTabRowsInserted:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    int offset = Global::controller->open_tabs()->count();
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::controller->preview_tabs()->webpage_(i+first);
        TabViewItem* item = [[TabViewItem alloc] initWithWebpage:w tabview:self];
        if (self.tabViewItems.count == 0) {
            [self addTabViewItem:item];
        } else {
            [self insertTabViewItem:item atIndex:(i+first+offset)];
        }
    }
}

- (void)onOpenTabRowsInserted:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i+first);
        TabViewItem* item;
        if (w->associated_frontend()) {
            item = [[TabViewItem alloc] initWithWebUI:(__bridge WebUI*)w->associated_frontend() webpage:w tabview:self];
        } else {
            item = [[TabViewItem alloc] initWithWebpage:w tabview:self];
        }
        if (self.tabViewItems.count == 0) {
            [self addTabViewItem:item];
        } else {
            [self insertTabViewItem:item atIndex:(i+first)];
        }
    }
}

- (void)onOpenTabRowsRemoved:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    auto current = self.tabViewItems;
    for (int i = 0; i < count; i++) {
        int remove_idx = i + first;
        NSTabViewItem* item = current[remove_idx];
        [self removeTabViewItem:item];
    }
}

// called when the tabs are reloaded
// typically once at the start of the application
// or when the page array is changed
- (void)updateSelection
{
    if (self.numberOfTabViewItems == 0) {
        [self reload];
    }
    if (Global::controller->current_tab_state() == Controller::TabStateNull) {
        [self selectTabViewItem:nil];
    } else if (Global::controller->current_tab_state() == Controller::TabStateOpen) {
        int i = Global::controller->current_open_tab_index();
        [self selectTabViewItemAtIndex:i];
    } else if (Global::controller->current_tab_state() == Controller::TabStatePreview) {
        int i = Global::controller->open_tabs()->count() + Global::controller->current_preview_tab_index();
        [self selectTabViewItemAtIndex:i];
    }
}

- (void)reload
{
    auto current = self.tabViewItems;
    for (TabViewItem* item in current)
    {
        [self removeTabViewItem:item];
        // [item release];
    }
    int open_size = Global::controller->open_tabs()->count();
    for (int i = 0; i < open_size; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        TabViewItem* c = [[TabViewItem alloc] initWithWebpage:w tabview:self];
        [self addTabViewItem:c];
    }
    int preview_size = Global::controller->preview_tabs()->count();
    for (int i = 0; i < preview_size; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        TabViewItem* c = [[TabViewItem alloc] initWithWebpage:w tabview:self];
        [self addTabViewItem:c];
    }
}

@end
