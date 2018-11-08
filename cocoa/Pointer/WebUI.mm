//
//  WebUI.m
//  Pointer
//
//  Created by Yu Li on 2018-08-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//
#import <WebKit/WebKit.h>
#import "WebUI.mm.h"
#import "TabView.mm.h"
#import "Extension/PMenu.h"
#import "Extension/PView.h"
#import "CppData.h"
#include <docviewer/global.hpp>

@implementation WebUI

@synthesize webpage = m_webpage;

- (void)mouseDown:(NSEvent*)event
{
    Global::controller->closeAllPopoversAsync();
    [super mouseDown:event];
}

- (instancetype)initWithWebpage:(Webpage_)webpage
                          frame:(NSRect)frame
                         config:(WKWebViewConfiguration*)config
{
    if (! config) {
        config = [[WKWebViewConfiguration alloc] init];
    }
    config.applicationNameForUserAgent = @"Version/11.1.2 Safari/605.1.15";
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"SearchWebView.js"))).toNSString() controller:config.userContentController];
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"OpenLinkInNewWindow.js"))).toNSString() controller:config.userContentController];
    self = [super initWithFrame:frame configuration:config];
    self->m_erroring_url = nil;
    self->m_redirected_from_error = false;
    self->m_new_request_is_download = false;
    self.UIDelegate = self;
    self.allowsBackForwardNavigationGestures = YES;
    self.allowsMagnification = YES;
    self.navigationDelegate = self;
    //    self.customUserAgent = @"Pointer";
    self.webpage = webpage;
    self.webpage->set_associated_frontend_async((__bridge void*)self);
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    self->m_error_page_view_controller = [[ErrorPageViewController alloc] init];
    [self addSubviewAndFill:self->m_error_page_view_controller.view];
    self->m_error_page_view_controller.view.hidden = YES;
    [self connect];
    return self;
}

- (void)dealloc
{
//    self.webpage->set_associated_frontend_async(nullptr);
}

- (void)connect
{
    QObject::connect(self.webpage.get(), &Webpage::url_changed,
                     [=](const Url& url, void const* sender)
    {
        if ((__bridge void*)self != sender) {
            NSString* u = url.full().toNSString();
            [self performSelectorOnMainThread:@selector(loadUri:) withObject:u waitUntilDone:YES];
        }
    });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_refresh,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_back,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_forward,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(goForward) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_stop,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_highlight_all,
                     [=](const QString& keyword) {
                        NSString* txt = keyword.toNSString();
                         [self performSelectorOnMainThread:@selector(highlightAllOccurencesOfString:) withObject:txt waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_clear,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(removeAllHighlights) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_next_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_prev_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::is_error_changed,
                     [=](int idx) {
                         [self performSelectorOnMainThread:@selector(handle_is_error_changed) withObject:nil waitUntilDone:YES];
                     });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float p = (float)[self estimatedProgress];
        self.webpage->set_load_progress_async(p);
    } else if ([keyPath isEqualToString:@"URL"]) {
        NSURL * _Nullable url = self.URL;
        if (url == nil) { return; }
        QString dest;
        if ([url.absoluteString hasPrefix:@"about:error:"]) {
            dest = QString::fromNSString([url.absoluteString substringFromIndex:12]);
        } else {
            dest = QString::fromNSString(url.absoluteString);
        }
        Global::controller->handleWebpageUrlChangedAsync(self.webpage, dest, (__bridge void*)self);
        NSString * _Nullable title = self.title;
        if (title && title.length > 0) {
            self.webpage->set_title_async(QString::fromNSString(title));
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        NSString * _Nullable title = self.title;
        self.webpage->set_title_async(QString::fromNSString(title));
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        self.webpage->set_can_go_back_async(self.canGoBack);
    } else if ([keyPath isEqualToString:@"canGoForward"]) {
        self.webpage->set_can_go_forward_async(self.canGoForward);
    }
}

- (void)handle_is_error_changed
{
    bool is_error = self.webpage->is_error();
    NSString* msg = self.webpage->error().toNSString();
    if (is_error) {
        self->m_error_page_view_controller.error_msg = msg;
        self->m_error_page_view_controller.view.hidden = NO;
    } else {
        self->m_error_page_view_controller.view.hidden = YES;
    }
}

- (void)loadUri:(NSString*)url
{
    NSURL* u = [[NSURL alloc] initWithString:url];
    NSURLRequest* r = [[NSURLRequest alloc] initWithURL:u];
    [self loadRequest:r];
}

- (void)webView:(WebUI *)webView
didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error
{
    if (error.code == 102) {
        // Frame Load Interrupted
        return;
    }
    if (error.code == -999) {
        // Too many requests
        return;
    }
    Url u = self.webpage->url();
    NSURL* url = u.toNSURL();
    self->m_erroring_url = url;
    self->m_redirected_from_error = true;
    QString desc = QString::fromNSString(error.localizedDescription);
    QString reason = QString::fromNSString(error.localizedFailureReason);
    QString suggest = QString::fromNSString(error.localizedRecoverySuggestion);
    QString message;
    if (! desc.isEmpty()) {
        message += desc + " ";
    }
    if (! reason.isEmpty()) {
        message += reason + " ";
    }
//    if (! suggest.isEmpty()) {
//        message += suggest + " ";
//    }
    self.webpage->handleErrorAsync(message);
    NSURL* redirect = [NSURL URLWithString:("about:error:" + u.full()).toNSString()];
    [webView loadRequest:[NSURLRequest requestWithURL:redirect]];
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
}

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WebUI *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // change url to https
    Url url(QUrl::fromNSURL(navigationAction.request.URL));
    if ([navigationAction.request.URL.scheme isEqualToString:@"http"]
        && navigationAction.targetFrame.isMainFrame)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        qDebug() << url.full().toNSString();
        [webView loadUri:url.full().toNSString()];
        return;
    }
    if (url.full().indexOf("about:error:") == 0) {
        if (self->m_redirected_from_error) {
            self->m_redirected_from_error = false;
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
            [webView loadUri:url.full().mid(12).toNSString()];
        }
        return;
    }
    self.webpage->handleSuccessAsync();
//    if (self.tab_state() == Controller::TabStatePreview && navigationAction.navigationType) {
//        Global::controller->newTabAsync(Controller::TabStateOpen, QUrl::fromNSURL(url), Controller::WhenCreatedViewCurrent, Controller::WhenExistsViewExisting);
//        return;
//    }
    if (navigationAction.modifierFlags & NSEventModifierFlagCommand
        && navigationAction.buttonNumber == 1)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        Webpage_ w = [(WebUI*)webView webpage];
        Global::controller->newTabAsync(Controller::TabStateOpen, url, Controller::WhenCreatedViewCurrent, Controller::WhenExistsViewExisting);
    } else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str
{
    NSString *searchjs = FileManager::readQrcFileS("SearchWebView.js").toNSString();
    [self evaluateJavaScript:searchjs completionHandler:(^(id, NSError *error){
        NSString *startSearch = [NSString stringWithFormat:@"pointerHighlightAllOccurencesOfString('%@')",str];
        [self evaluateJavaScript:startSearch completionHandler:(^(id, NSError *error){
            [self evaluateJavaScript:@"pointerSearchResultCount" completionHandler:(^(id result, NSError *error){
                Global::controller->updateWebpageFindTextFoundAsync(self.webpage, [(NSNumber*)result intValue]);
            })];
        })];
    })];
    return 0;
}

- (void)removeAllHighlights
{
    [self evaluateJavaScript:@"pointerRemoveAllHighlights()" completionHandler:(^(id, NSError *error){})];
}

- (void)scrollToNthHighlight:(NSNumber*)idx
{
    NSString *js = [NSString stringWithFormat:@"pointerScrollToNthHighlight('%@')", idx];
    [self evaluateJavaScript:js completionHandler:(^(id, NSError *error){})];
}

+ (void)addUserScriptAfterLoaded:(NSString*)js
                      controller:(WKUserContentController*)controller
{
    WKUserScript* script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
    [controller addUserScript:script];
}

- (id)validRequestorForSendType:(NSPasteboardType)sendType
                     returnType:(NSPasteboardType)returnType
{
    return nil;
}

- (void)willOpenMenu:(NSMenu *)menu
           withEvent:(NSEvent *)event
{
    [menu filterMenuItems];
    NSArray* itemarray = menu.itemArray;
    // dirty hacking
    // steal the private API from WKWebView
    for (int i = itemarray.count - 1; i >= 0; i--) {
        NSMenuItem* item = itemarray[i];
        if ([item.title containsString:@"Open Link in New Window"])
        {
            NSMenuItem* m_wkwebview_menu_open_in_new_window_clone = [item copy];
            m_wkwebview_menu_open_in_new_window_clone.title = @"Download Link as File";
            m_wkwebview_menu_open_in_new_window_clone.target = self;
            m_wkwebview_menu_open_in_new_window_clone.action = @selector(downloadLink:);
            self->m_wkwebview_menu_target_for_open_in_new_window = item.target;
            self->m_wkwebview_menu_action_for_open_in_new_window = item.action;
            [menu insertItem:m_wkwebview_menu_open_in_new_window_clone atIndex:1];
            break;
        }
    }
    // dirty ends
}

//
- (void)downloadLink:(id)sender
{
    self->m_new_request_is_download = true;
    [self->m_wkwebview_menu_target_for_open_in_new_window performSelector:self->m_wkwebview_menu_action_for_open_in_new_window withObject:sender];
}

- (void)webView:(WebUI *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (webView.webpage->is_for_download()) {
        NSURL* url = navigationResponse.response.URL;
        NSString* filename = navigationResponse.response.suggestedFilename;
        Global::controller->downloadFileFromUrlAndRenameAsync(webView.webpage->url(), QString::fromNSString(filename));
        Global::controller->closeTabAsync(Controller::TabStateOpen, webView.webpage);
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    if (navigationResponse.canShowMIMEType) {
        decisionHandler(WKNavigationResponsePolicyAllow);
//        if ([navigationResponse.response.MIMEType containsString:@"pdf"]) {
//            NSURL* url = navigationResponse.response.URL;
//            NSString* filename = navigationResponse.response.suggestedFilename;
//            Global::controller->downloadFileFromUrlAndRenameAsync(QString::fromNSString(url.absoluteString), QString::fromNSString(filename));
//        }
    } else {
        decisionHandler(WKNavigationResponsePolicyCancel);
        NSURL* url = navigationResponse.response.URL;
        NSString* filename = navigationResponse.response.suggestedFilename;
        Global::controller->downloadFileFromUrlAndRenameAsync(QString::fromNSString(url.absoluteString), QString::fromNSString(filename));
    }
}

- (WKWebView *)webView:(WebUI *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures
{
    Url url = Url(QUrl::fromNSURL(navigationAction.request.URL));
    Webpage_ new_webpage = shared<Webpage>(url);
    WebUI* new_webview = [[WebUI alloc] initWithWebpage:new_webpage frame:self.bounds config:configuration];
    new_webpage->set_associated_frontend((__bridge void*)new_webview);
    if (m_new_request_is_download) {
        m_new_request_is_download = false;
        new_webpage->set_is_for_download(true);
    }
    new_webpage->moveToThread(Global::qCoreApplicationThread);
    if (Global::controller->open_tabs()->findTab(webView.webpage) >= 0) {
        Global::controller->newTabAsync(0, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
    } else {
        Global::controller->newTabAsync(0, Controller::TabStatePreview, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
    }
    return new_webview;
}

- (void)webView:(WKWebView *)webView
runOpenPanelWithParameters:(WKOpenPanelParameters *)parameters
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSArray<NSURL *> *URLs))completionHandler
{
    NSOpenPanel* open_panel = [NSOpenPanel openPanel];
    open_panel.allowsMultipleSelection = parameters.allowsMultipleSelection;
    open_panel.canChooseDirectories = parameters.allowsDirectories;
    [open_panel beginWithCompletionHandler:^(NSModalResponse result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray* urls = [open_panel URLs];
            completionHandler(urls);
        }
    }];
}

@end


