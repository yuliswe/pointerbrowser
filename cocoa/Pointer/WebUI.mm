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
#include <docviewer/global.hpp>

@implementation WebUI

@synthesize webpage = m_webpage;

- (void)dealloc
{
}

- (void)mouseDown:(NSEvent*)event
{
    Global::controller->hideCrawlerRuleTableAsync();
    if (event.modifierFlags & NSEventModifierFlagCommand) {
        NSString *js = [NSString stringWithFormat:@"pointerEnableOpenLinkInNewWindow()"];
        [self evaluateJavaScript:js completionHandler:(^(id, NSError *error){
            [super mouseDown:event];
        })];
    } else {
        NSString *js = [NSString stringWithFormat:@"pointerDisableOpenLinkInNewWindow()"];
        [self evaluateJavaScript:js completionHandler:(^(id, NSError *error){
            [super mouseDown:event];
        })];
    }
}

- (instancetype)initWithTabItem:(TabViewItem*)tabItem
{
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    config.applicationNameForUserAgent = @"Version/11.1.2 Safari/605.1.15";
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"SearchWebView.js"))).toNSString() controller:config.userContentController];
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"OpenLinkInNewWindow.js"))).toNSString() controller:config.userContentController];
    self = [super initWithFrame:[tabItem.view bounds] configuration:config];
//    self.tab = tabItem;
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
    [self connect];
    return self;
}

- (void)connect
{
    QObject::connect(self.webpage.get(), &Webpage::url_changed,
                     [=](const Url& url)
    {
        NSString* u = url.full().toNSString();
        [self performSelectorOnMainThread:@selector(loadUri:) withObject:u waitUntilDone:YES];
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
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        float p = (float)[self estimatedProgress];
        Global::controller->updateWebpageProgressAsync(self.webpage, p);
    } else if ([keyPath isEqualToString:@"URL"]) {
        NSURL * _Nullable url = self.URL;
        if (url == nil) { return; }
        Global::controller->updateWebpageUrlAsync(self.webpage, QUrl::fromNSURL(url));
    } else if ([keyPath isEqualToString:@"title"]) {
        NSString * _Nullable title = self.title;
        Global::controller->updateWebpageTitleAsync(self.webpage, QString::fromNSString(title));
    }
}

- (void)loadUri:(NSString*)url
{
    NSURL* u = [[NSURL alloc] initWithString:url];
    NSURLRequest* r = [[NSURLRequest alloc] initWithURL:u];
    [self loadRequest:r];
}

- (void)webView:(WKWebView *)webView
didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
}

- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
//    self.webpage->updateTitleAsync(QString::fromNSString(self.title));
//    NSURL * _Nullable url = self.URL;
//    self.webpage->updateUrlAsync(QUrl::fromNSURL(url));
}

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(WKNavigation *)navigation {
//    self.webpage->updateTitleAsync(QString::fromNSString(self.title));
//    NSURL * _Nullable url = self.URL;
//    self.webpage->updateUrlAsync(QUrl::fromNSURL(url));
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
//    self.webpage->updateTitleAsync(QString::fromNSString(self.title));
//    NSURL * _Nullable url = self.URL;
//    self.webpage->updateUrlAsync(QUrl::fromNSURL(url));
}

- (void)webView:(WKWebView *)webView
didFinishNavigation:(WKNavigation *)navigation {
//    NSString * _Nullable title = self.title;
//    self.webpage->updateTitleAsync(QString::fromNSString(title));
//    NSURL * _Nullable url = self.URL;
//    self.webpage->updateUrlAsync(QUrl::fromNSURL(url));
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation {
//    self.webpage->updateTitleAsync(QString::fromNSString(self.title));
//    NSURL * _Nullable url = self.URL;
//    self.webpage->updateUrlAsync(QUrl::fromNSURL(url));
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
        Global::controller->newTabAsync(Controller::TabStateOpen, QUrl::fromNSURL(url), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
    } else {
        Global::controller->newTabAsync(Controller::TabStatePreview, QUrl::fromNSURL(url), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
    }
    return nil;
}
@end
