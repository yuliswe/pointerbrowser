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

- (instancetype)initWithTabItem:(TabViewItem*)tabItem
{
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent = @"Version/11.1.2 Safari/605.1.15";
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"SearchWebView.js"))).toNSString() controller:config.userContentController];
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"OpenLinkInNewWindow.js"))).toNSString() controller:config.userContentController];
    self = [super initWithFrame:[tabItem.view bounds] configuration:config];
    self->m_erroring_url = nil;
    self->m_redirected_from_error = false;
    static WebUIDelegate* uidelegate = [[WebUIDelegate alloc] init];
    self.UIDelegate = uidelegate;
    self.allowsBackForwardNavigationGestures = YES;
    self.allowsMagnification = YES;
    self.navigationDelegate = self;
//    self.customUserAgent = @"Pointer";
    self.webpage = tabItem.webpage;
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
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"about:error:"]) {
        if (self->m_redirected_from_error) {
            self->m_redirected_from_error = false;
            decisionHandler(WKNavigationActionPolicyAllow);
        } else {
            decisionHandler(WKNavigationActionPolicyCancel);
            [webView loadUri:[navigationAction.request.URL.absoluteString substringFromIndex:12]];
        }
        return;
    }
    self.webpage->handleSuccessAsync();
    if (navigationAction.modifierFlags & NSEventModifierFlagCommand
        && navigationAction.buttonNumber == 1)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        Webpage_ w = [(WebUI*)webView webpage];
        NSURL* url = navigationAction.request.URL;
        Global::controller->newTabAsync(Controller::TabStateOpen, QUrl::fromNSURL(url), Controller::WhenCreatedViewCurrent, Controller::WhenExistsViewExisting);
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
}

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (navigationResponse.canShowMIMEType) {
        decisionHandler(WKNavigationResponsePolicyAllow);
    } else {
        decisionHandler(WKNavigationResponsePolicyCancel);
        NSURL* url = navigationResponse.response.URL;
        NSString* filename = navigationResponse.response.suggestedFilename;
        Global::controller->downloadFileFromUrlAndRenameAsync(QString::fromNSString(url.absoluteString), QString::fromNSString(filename));
    }
}

@end

@implementation WebUIDelegate
- (WKWebView *)webView:(WKWebView *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures
{
    Webpage_ w = [(WebUI*)webView webpage];

    NSURL* url = navigationAction.request.URL;
    if (Global::controller->open_tabs()->findTab(w.get()) >= 0) {
        Global::controller->newTabAsync(Controller::TabStateOpen, QUrl::fromNSURL(url), Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
    } else {
        Global::controller->newTabAsync(Controller::TabStatePreview, QUrl::fromNSURL(url), Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
    }
    return nil;
}
@end
