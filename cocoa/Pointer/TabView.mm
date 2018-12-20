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
#include "BrowserWindow.mm.h"

@implementation TabViewController

@synthesize address_bar = m_address_bar;

- (void)insertChildViewControllerWithWebpage:(Webpage_)webpage frame:(NSRect)frame index:(NSUInteger)index
{
    NSViewController* childViewController = [[NSViewController alloc] init];
    WebUI* webui = [[WebUI alloc] initWithWebpage:webpage frame:frame config:nil];
    childViewController.view = webui;
    if (webpage->url().full() == "about:eula") {
        NSString* eula_path = [[NSBundle mainBundle] pathForResource:@"eula" ofType:@"html"];
        NSString* eula = [NSString stringWithContentsOfFile:eula_path encoding:NSUTF8StringEncoding error:nil];
        [webui loadHTMLString:eula baseURL:webpage->url().toNSURL()];
    } else {
        [webui loadUri:webpage->url().full().toNSString()];
    }
    [self insertChildViewController:childViewController atIndex:index];
}


- (void)addChildViewControllerWithWebUI:(WebUI*)webui webpage:(Webpage_)webpage
{
    NSViewController* childViewController = [[NSViewController alloc] init];
    childViewController.view = webui;
    [self insertChildViewController:childViewController atIndex:0];
}

- (void)removeChildViewControllerAtIndex:(NSInteger)index
{
    NSViewController* childViewController = self.childViewControllers[index];
    WebUI* webUI = (WebUI*)childViewController.view;
    [webUI disconnect];
    [super removeChildViewControllerAtIndex:index];
    if (Global::controller->next_tab_state() == Controller::TabStateOpen) {
        self.selectedTabViewItemIndex = Global::controller->next_tab_index();
    } else if (Global::controller->next_tab_state() == Controller::TabStatePreview) {
        self.selectedTabViewItemIndex = Global::controller->open_tabs()->count() + Global::controller->next_tab_index();
    } else if (Global::controller->next_tab_state() == Controller::TabStateNull) {
        self.selectedTabViewItemIndex = -1;
    }
}


- (TabViewController*)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
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
                         [self performSelectorOnMainThread:@selector(handlePreviewTabRowsRemoved:) withObject:args waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->preview_tabs().get(),
                     &TabsModel::modelReset,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handlePreviewTabModelReset) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->workspace_tabs().get(),
                     &TabsModel::rowsInserted,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(handleWorkspaceTabRowsInserted:) withObject:args waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->workspace_tabs().get(),
                     &TabsModel::rowsRemoved,
                     [=](const QModelIndex &parent, int first, int last) {
                         NSDictionary* args = @{@"first" : [NSNumber numberWithInt:first], @"last": [NSNumber numberWithInt:last]};
                         [self performSelectorOnMainThread:@selector(handleWorkspaceTabRowsRemoved:) withObject:args waitUntilDone:YES];
                     });
    QObject::connect(Global::controller->workspace_tabs().get(),
                     &TabsModel::modelReset,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handleWorkspaceTabModelReset) withObject:nil waitUntilDone:YES];
                     });
    // selection changed signal should only be connected after view is for sure loaded
    QObject::connect(Global::controller,
                     &Controller::current_tab_webpage_changed,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handleIndexesChangesInController) withObject:nil waitUntilDone:YES];
                     });
    self.transitionOptions = NSViewControllerTransitionNone;
    self.tabStyle = NSTabViewControllerTabStyleUnspecified;
    [self loadView];
    return self;
}

- (void)viewDidLoad
{
    self.view.frame = self->m_parent_view.bounds;
    self.view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    [self->m_parent_view addSubview:self.view];
    [self reload];
}

- (void)handleOpenTabsMoved:(NSDictionary*)indices
{
    int from = [indices[@"from"] intValue];
    int to = [indices[@"to"] intValue];
    NSMutableArray* items_arr = [self.tabViewItems mutableCopy];
    TabItemView* item = (TabItemView*)items_arr[from];
    [items_arr removeObjectsAtIndexes:[NSIndexSet indexSetWithIndex:from]];
    [items_arr insertObject:item atIndex:(to <= from ? to : to - 1)];
    self.tabViewItems = items_arr;
    if (self.selectedTabViewItemIndex == from) {
        self.selectedTabViewItemIndex = (to <= from ? to : to - 1);
    }
}

- (void)handlePreviewTabRowsRemoved:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    int offset = Global::controller->open_tabs()->count();
    for (int i = count - 1; i >= 0; i--) {
        [self removeChildViewControllerAtIndex:(i+first+offset)];
    }
}

- (void)handlePreviewTabModelReset
{
    int offset = Global::controller->open_tabs()->count();
    for (int i = self.childViewControllers.count - Global::controller->workspace_tabs()->count() - 1; i >= offset; i--) {
        [self removeChildViewControllerAtIndex:i];
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
        [self insertChildViewControllerWithWebpage:w frame:self->m_parent_view.bounds index:(i+first+offset)];
    }
}

- (void)onOpenTabRowsInserted:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i+first);
        if (w->associated_frontend_webview_object()) {
            [self addChildViewControllerWithWebUI:(__bridge_transfer WebUI*)w->associated_frontend_webview_object() webpage:w];
        } else {
            [self insertChildViewControllerWithWebpage:w frame:self->m_parent_view.bounds index:(i+first)];
        }
    }
}

- (void)onOpenTabRowsRemoved:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    for (int i = count - 1; i >= 0; i--) {
        int remove_idx = i + first;
        [self removeChildViewControllerAtIndex:remove_idx];
    }
}


- (void)handleWorkspaceTabRowsRemoved:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    int offset = Global::controller->open_tabs()->count() + Global::controller->preview_tabs()->count();
    for (int i = count - 1; i >= 0; i--) {
        [self removeChildViewControllerAtIndex:(i+first+offset)];
    }
}

- (void)handleWorkspaceTabModelReset
{
    int offset = Global::controller->open_tabs()->count() + Global::controller->preview_tabs()->count();
    for (int i = self.childViewControllers.count - 1; i >= offset; i--) {
        [self removeChildViewControllerAtIndex:i];
    }
}

- (void)handleWorkspaceTabRowsInserted:(NSDictionary*)args
{
    int first = [args[@"first"] intValue];
    int last = [args[@"last"] intValue];
    
    int count = last - first + 1;
    int offset = Global::controller->open_tabs()->count() + Global::controller->preview_tabs()->count();
    for (int i = 0; i < count; i++) {
        Webpage_ w = Global::controller->workspace_tabs()->webpage_(i+first);
        [self insertChildViewControllerWithWebpage:w frame:self->m_parent_view.bounds index:(i+first+offset)];
    }
}
// called when the tabs are reloaded
// typically once at the start of the application
// or when the page array is changed
- (void)handleIndexesChangesInController
{
    if (self.childViewControllers.count == 0) {
        [self reload];
    }
    // if entered full screen video mode
    if ([self.view.window.windowController isFullscreenMode]) {
        [self.currentWebUI exitVideoFullscreen];
        [self.view.window.windowController exitFullscreenMode];
    }
    if (Global::controller->current_tab_state() == Controller::TabStateNull) {
        self.selectedTabViewItemIndex = -1;
    } else if (Global::controller->current_tab_state() == Controller::TabStateOpen) {
        int i = Global::controller->current_open_tab_index();
        self.selectedTabViewItemIndex = i;
    } else if (Global::controller->current_tab_state() == Controller::TabStatePreview) {
        int i = Global::controller->open_tabs()->count() + Global::controller->current_preview_tab_index();
        self.selectedTabViewItemIndex = i;
    } else if (Global::controller->current_tab_state() == Controller::TabStateWorkspace) {
        int i = Global::controller->open_tabs()->count() + Global::controller->preview_tabs()->count() + Global::controller->current_tab_webpage_associated_tabs_model_index();
        self.selectedTabViewItemIndex = i;
    }
}

- (void)reload
{
    auto current = self.tabViewItems;
    for (int i = self.childViewControllers.count - 1; i >= 0; i--)
    {
        [self removeChildViewControllerAtIndex:i];
    }
    int open_size = Global::controller->open_tabs()->count();
    for (int i = 0; i < open_size; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        [self insertChildViewControllerWithWebpage:w frame:self->m_parent_view.bounds index:i];
    }
    int preview_size = Global::controller->preview_tabs()->count();
    for (int i = 0; i < preview_size; i++) {
        Webpage_ w = Global::controller->open_tabs()->webpage_(i);
        [self insertChildViewControllerWithWebpage:w frame:self->m_parent_view.bounds index:(open_size+i)];
    }
}

- (void)downloadAsWebArchive
{
    int idx = self.selectedTabViewItemIndex;
    if (idx == -1) { return; }
    NSViewController* controller = self.childViewControllers[idx];
    WebUI* webUI = (WebUI*)controller.view;
    [webUI downloadAsWebArchive];
}

- (void)print
{
    int idx = self.selectedTabViewItemIndex;
    if (idx == -1) { return; }
    NSViewController* controller = self.childViewControllers[idx];
    WebUI* webUI = (WebUI*)controller.view;
    [webUI print];
}

- (void)downloadAsPDF
{
    int idx = self.selectedTabViewItemIndex;
    if (idx == -1) { return; }
    NSViewController* controller = self.childViewControllers[idx];
    WebUI* webUI = (WebUI*)controller.view;
    [webUI downloadAsPDF];
}

- (WebUI*)currentWebUI
{
    return (WebUI*)self.childViewControllers[self.selectedTabViewItemIndex].view;
}
@end
