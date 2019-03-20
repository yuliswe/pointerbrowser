//
//  WebUI.m
//  Pointer
//
//  Created by Yu Li on 2018-08-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//
#import <WebKit/WebKit.h>
#import <Quartz/Quartz.h>
#import "WebUI.mm.h"
#import "TabView.mm.h"
#import "Extension/PMenu.h"
#import "Extension/PView.h"
#import "CppData.h"
#import "BrowserWindow.mm.h"
#include <docviewer/global.hpp>

@implementation WebUI

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
    // when user opens a link with target=_blank, createWebViewWithConfiguration is called
    // with the current WKWebViewConfiguration, resulting in double scriptMessageHandler,
    // and wkwebview throws an exception. So must remove the duplicated first.
    [config.userContentController removeScriptMessageHandlerForName:@"pointerbrowser"];
    [config.userContentController addScriptMessageHandler:self name:@"pointerbrowser"];
    [config.preferences setValue:@YES forKey:@"developerExtrasEnabled"];
    [config.userContentController removeAllUserScripts];
    [WebUI addUserScriptBeforeLoading:(FileManager::readQrcFileS(QString::fromNSString(@"Fullscreen.js"))).toNSString() controller:config.userContentController];
    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"SearchWebView.js"))).toNSString() controller:config.userContentController];
//    [WebUI addUserScriptAfterLoaded:(FileManager::readQrcFileS(QString::fromNSString(@"OpenLinkInNewWindow.js"))).toNSString() controller:config.userContentController];
    static WKProcessPool* processPool = [[WKProcessPool alloc] init];
    config.processPool = processPool;
    self = [super initWithFrame:frame configuration:config];
//    self.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:59.0) Gecko/20100101 Firefox/59.0";
    self.customUserAgent = @"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0.1 Safari/605.1.15";
    self.is_pesudo_url = false;
    self->m_new_request_is_download = false;
    self.webpage = webpage;
    if (! webpage->associated_frontend_webview_object()) {
        self.webpage->set_associated_frontend_webview_object_async((__bridge void*)self);
    }
    self.UIDelegate = self;
    self.allowsBackForwardNavigationGestures = YES;
    self.allowsMagnification = YES;
    self.navigationDelegate = self;
    self.error_page_view_controller = [[ErrorPageViewController alloc] init];
    [self addSubviewAndFill:self.error_page_view_controller.view];
    [self.error_page_view_controller hide];
    [self connect];
    return self;
}

- (void)disconnect
{
    self.webpage->disconnect();
    self.webpage->set_associated_frontend_webview_object_async(nullptr);
    // script message handler causes a retain loop,
    // see https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak/26383032#26383032
    [self.configuration.userContentController removeScriptMessageHandlerForName:@"pointerbrowser"];
    [self loadUrlString:@"about:blank"];
}

- (void)connect
{
    [self addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"URL" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"hasOnlySecureContent" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:nil];
    QObject::connect(self.webpage.get(), &Webpage::signal_tf_load,
                     [=](Url const& url)
    {
        NSString* u = url.full().toNSString();
        [self performSelectorOnMainThread:@selector(loadUrlString:) withObject:u waitUntilDone:YES];
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
                         if (self.webpage->is_pdf() && self.pdfView) {
                             return [self.pdfView performSelectorOnMainThread:@selector(findHighlightAll:) withObject:txt waitUntilDone:YES];
                         }
                         [self performSelectorOnMainThread:@selector(highlightAllOccurencesOfString:) withObject:txt waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_clear,
                     [=]() {
                         if (self.webpage->is_pdf() && self.pdfView) {
                             return [self.pdfView performSelectorOnMainThread:@selector(findClear) withObject:nil waitUntilDone:YES];
                         }
                         [self performSelectorOnMainThread:@selector(removeAllHighlights) withObject:nil waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_next_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         if (self.webpage->is_pdf() && self.pdfView) {
                             return [self.pdfView performSelectorOnMainThread:@selector(findScrollToNextHighlight) withObject:nil waitUntilDone:YES];
                         }
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_prev_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         if (self.webpage->is_pdf() && self.pdfView) {
                             return [self.pdfView performSelectorOnMainThread:@selector(findScrollToPreviousHighlight) withObject:nil waitUntilDone:YES];
                         }
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:YES];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::loading_state_changed,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(handle_loading_state_changed) withObject:nil waitUntilDone:YES];
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
    } else if ([keyPath isEqualToString:@"progress.fractionCompleted"]) {
        NSProgress* p = [(NSURLSessionDownloadTask*)object progress];
        self.webpage->set_load_progress_async(p.fractionCompleted);
    } else if ([keyPath isEqualToString:@"URL"]) {
        /* Only SPAs need to be handled here */
        if (self.webpage->loading_state() != Webpage::LoadingStateLoaded) {
            return;
        }
        NSURL * _Nullable url = self.URL;
        if (url == nil) { return; }
        /* in a single page application, url changes without triggering decidePolicyForNavigationAction
            here we need to make url change in preview mode open new pages for SPAs */
        if (self.webpage->associated_tabs_model()
            && self.webpage->url() != Url(QUrl::fromNSURL(url))
            && self.webpage->loading_state() == Webpage::LoadingStateLoaded
            && self.webpage->associated_tabs_model() != Global::controller->open_tabs().get()
            && self.canGoBack
            && ! self.is_pesudo_url)
        {
            Global::controller->newTabByUrlAsync(self.webpage, Controller::TabStateOpen, Url(QUrl::fromNSURL(url)), Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
            self.webpage->set_loading_state_direct(Webpage::LoadingStateLoading);
            [self loadUrlString:self.webpage->url().full().toNSString()];
            return;
        }
        NSString* dest = [self removePesudoUrlPrefix:url];
        Global::controller->handleWebpageUrlDidChange(self.webpage, QString::fromNSString(dest));
        NSString * _Nullable title = self.title;
        if (title && title.length > 0) {
            Global::controller->handleWebpageTitleChangedAsync(self.webpage, QString::fromNSString(title), (__bridge void*)self);
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        NSString* title = self.title;
        Global::controller->handleWebpageTitleChangedAsync(self.webpage, QString::fromNSString(title), (__bridge void*)self);
    } else if ([keyPath isEqualToString:@"canGoBack"]) {
        self.webpage->set_can_go_back_async(self.canGoBack);
    } else if ([keyPath isEqualToString:@"canGoForward"]) {
        self.webpage->set_can_go_forward_async(self.canGoForward);
    } else if ([keyPath isEqualToString:@"hasOnlySecureContent"]) {
        self.webpage->set_is_secure_async(self.hasOnlySecureContent);
    }
}

- (NSString*)removePesudoUrlPrefix:(NSURL*)nsurl
{
    NSString* decoded = [nsurl.absoluteString stringByRemovingPercentEncoding];
    if ([decoded hasPrefix:self.errorPesudoUrlPrefix]) {
        return [decoded substringFromIndex:self.errorPesudoUrlPrefix.length];
    }
    if ([decoded hasPrefix:self.httpWarningPesudoUrlPrefix]) {
        return [decoded substringFromIndex:self.httpWarningPesudoUrlPrefix.length];
    }
    return decoded;
}

- (void)reload
{
    if (self.webpage->is_pdf()) {
        [self loadUrlString:self.webpage->url().full().toNSString()];
    } else {
        [super reload];
    }
}

- (void)handle_loading_state_changed
{
    if (self.webpage->loading_state() == Webpage::LoadingStateError)
    {
        self.is_pesudo_url = true;
        [self loadUrlString:("about:error:"+self.webpage->url().full()).toNSString()];
    } else if (self.webpage->loading_state() == Webpage::LoadingStateHttpUserConscentRequired)
    {
        self.is_pesudo_url = true;
        NSString* urlstr = ("about:http-warning:"+self.webpage->url().full()).toNSString();
        [self loadUrlString:urlstr];
    }
}

- (void)loadUrlString:(NSString*)url
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
        /* Frame Load Interrupted */
        return;
    }
    if (error.code == -999) {
        /* Too many requests */
        return;
    }
    Url u = self.webpage->url();
    NSURL* url = u.toNSURL();
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
    /* webpage.loading_state will be set to LoadStateError,
     then the loading_state_changed listener will make webView load a pesudo URL */
    self.is_pesudo_url = true;
    /* When navigation fails, the URL will be set to the previous URL by cocoa.
     In case this happens before is_pesudo_url flag is set, here we manually set the webpage.url.
     Otherwise webpage.url would be wrong. */
    Global::controller->handleWebpageUrlDidChange(self.webpage, u.full());
    self.webpage->handleErrorAsync(message);
}

- (void)webView:(WebUI *)webView
didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation
{
    self.webpage->set_loading_state_direct(Webpage::LoadingStateLoading);
}

- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
}

- (void)webView:(WebUI *)webView
didFinishNavigation:(WKNavigation *)navigation {
    NSString* title = self.title;
    if (title.length > 0) {
        Global::controller->handleWebpageTitleChangedAsync(self.webpage, QString::fromNSString(title), (__bridge void*)self);
    }
    if (! self.is_pesudo_url) {
        self.webpage->handleSuccessAsync();
    }
    self.is_pesudo_url = false;
}

- (void)exitVideoFullscreen
{
    [self evaluateJavaScript:@"document.exitFullscreen()" completionHandler:^(id _Nullable, NSError * _Nullable error) {
        // none
    }];
}

- (void)webView:(WKWebView *)webView
didCommitNavigation:(WKNavigation *)navigation {
    if ([self.window.windowController isFullscreenMode]) {
        [self.window.windowController exitFullscreenMode];
    }
}

- (void)conscentWebpageHttpUrlThenReload
{
    Global::controller->conscentHttpWebpageUrlChange(self.webpage);
    /* Due to the way we implemented this, there's a bug that I'm not sure whether is fixable:
     when user conscent HTTP url, the page refreshes, leaving the about:warning-http:url in the
     back-forward-list. User cannot go back to previous pages anymore. We need to be able to edit
     the back-forward-list to fix this, which currently has no API. */
    [self loadUrlString:self.webpage->url().full().toNSString()];
}

- (NSString*)errorPesudoUrlPrefix
{
    return @"about:error:";
}

- (NSString*)httpWarningPesudoUrlPrefix
{
    return @"about:http-warning:";
}

- (void)webView:(WebUI *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    /* Only want to handle main frame requests */
    if (navigationAction.targetFrame && ! navigationAction.targetFrame.isMainFrame) {
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    NSURL* nsurl = navigationAction.request.URL;
    Url url(QUrl::fromNSURL(nsurl));
    QString urlfullstr = url.full();
    /* is this a pesudo url? */
    NSString* errorPesudoUrlPrefix = self.errorPesudoUrlPrefix;
    NSString* httpWarningPesudoUrlPrefix = self.httpWarningPesudoUrlPrefix;
    BOOL isError = [nsurl.absoluteString hasPrefix:errorPesudoUrlPrefix];
    BOOL isHttpWarning = [nsurl.absoluteString hasPrefix:httpWarningPesudoUrlPrefix];
    if (isError || isHttpWarning) {
//        if (self.is_pesudo_url) {
            decisionHandler(WKNavigationActionPolicyAllow);
            if (isError) {
                [self.error_page_view_controller showWithTitle:@"Pointer Could Not Open the Page" message:self.webpage->error().toNSString() yesTarget:self yesSelector:nil noTarget:nil noSelector:nil];
            } else if (isHttpWarning) {
                [self.error_page_view_controller showWithTitle:@"Connection Is Not Secure" message:@"You are about to visit a website via unencrypted HTTP connection. Everyone in the network may be able to see your sent and received data as plain text. You should use HTTPS whenever possible. Do you still want to visit this page?" yesTarget:self yesSelector:@selector(conscentWebpageHttpUrlThenReload) noTarget:self noSelector:@selector(goBack)];
            }
            return;
//        } else {
            /* User visits the pesudo url directly, for example, on goBack event */
            /* Whenever WKNavigationActionPolicyCancel is used, URL is reset to its previous state.
             Set the is_pesudo_url flag so that the url change listener does not pick up the reset.
             Then manually set the new URL on weboage. */
//            self.is_pesudo_url = true;
//            decisionHandler(WKNavigationActionPolicyAllow);
//            NSString* modifiedUrlStr = [self removePesudoUrlPrefix:nsurl];
//            Url modifiedUrl(QString::fromNSString(modifiedUrlStr));
//            Global::controller->handleWebpageUrlDidChange(self.webpage, modifiedUrl);
            /* Due to the way this is implemented, there's a bug that's not fixable without APIs that
             allows us to edit the back-forward-list. When user visits a about:warning-http:url page directly
             via back/forward/refresh, the about:warning-http:url page is left in the back-forward-list, and
             everything that page is hit by back/forward/refresh, a new page with the original url is opened,
             overwriting later histories. */
//            [self loadUrlString:modifiedUrlStr];
//            return;
//        }
    }
    /* reset */
    [self.error_page_view_controller hide];
    self.is_pesudo_url = false;
    Webpage_ w = webView.webpage;
    bool is_preview_tab = w->associated_tabs_model() == Global::controller->preview_tabs().get();
    bool is_workspace_tab = w->associated_tabs_model() == Global::controller->workspace_tabs().get();
    bool is_loaded = w->loading_state() == Webpage::LoadingStateLoaded;
    WKNavigationType type = navigationAction.navigationType;
    /* open new tab if command + click link */
    if (navigationAction.modifierFlags & NSEventModifierFlagCommand
        && navigationAction.buttonNumber == 1)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        Webpage_ new_webpage = Webpage_::create(url);
        Global::controller->newTabByWebpageCopyAsync(self.webpage, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewCurrent, Controller::WhenExistsViewExisting);
        return;
    }
    /* If the this is a HTTP request on a page not newly created, open new window */
    if (url.scheme() == "http"
        && (self.webpage->url().scheme() != "http" || ! self.webpage->allow_http())
        && (self.webpage->loading_state() == Webpage::LoadingStateLoaded || self.webpage->loading_state() == Webpage::LoadingStateLoading)
        && type == WKNavigationTypeLinkActivated)
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        Webpage_ new_webpage = Webpage_::create(url);
        Global::controller->newTabByWebpageCopyAsync(self.webpage, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
        return;
    }
    /* if request is from preview or workspace, open new window */
    if ((is_preview_tab || is_workspace_tab) && is_loaded
        && type != WKNavigationTypeReload)
    {
        Webpage_ new_webpage = Webpage_::create(url);
        Global::controller->newTabByWebpageCopyAsync(self.webpage, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    /* open new tab if link is to a pdf */
    if ([nsurl.absoluteString hasSuffix:@".pdf"] && ! self.webpage->is_pdf())
    {
        decisionHandler(WKNavigationActionPolicyCancel);
        Webpage_ new_webpage = Webpage_::create(url);
        Global::controller->newTabByWebpageCopyAsync(self.webpage, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsViewExisting);
        return;
    }
    Controller::UrlChangeDecision decision = Global::controller->handleWebpageUrlWillChange(self.webpage, url);
    if (decision == Controller::UrlChangeDecisionRequreUserHttpConscent) {
        /* loading_state listener will now make webView load about:http-warning:url,
         but before that, self.URL is temporarily reset to the previous URL.
         We set the is_pesudo_url so that the URL listener ignores this URL change. */
        self.is_pesudo_url = true;
        decisionHandler(WKNavigationActionPolicyCancel);
        /* In case this happens before is_pesudo_url flag is set, here we manually set the webpage.url.
         Otherwise webpage.url would be wrong. */
        Global::controller->handleWebpageUrlDidChange(self.webpage, urlfullstr);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
    Global::controller->handleWebpageUrlDidChange(self.webpage, urlfullstr);
    self.webpage->handleLoadingDidStartAsync();
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

+ (void)addUserScriptBeforeLoading:(NSString*)js
                      controller:(WKUserContentController*)controller
{
    WKUserScript* script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
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
        File_ file = Global::controller->createFileDownloadFromUrl(webView.webpage->url(), QString::fromNSString(filename));
        Global::controller->startFileDownloadAsync(file);
        Global::controller->closeTabAsync(Controller::TabStateOpen, webView.webpage);
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    if (! navigationResponse.canShowMIMEType
        || ([navigationResponse.response.MIMEType isEqualToString:@"application/pdf"]
            && ! navigationResponse.forMainFrame))
    {
        NSURL* url = navigationResponse.response.URL;
        NSString* filename = navigationResponse.response.suggestedFilename;
        File_ file = Global::controller->createFileDownloadFromUrl(Url(QUrl::fromNSURL(url)), QString::fromNSString(filename));
        Global::controller->startFileDownloadAsync(file);
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    } else if ([navigationResponse.response.MIMEType isEqualToString:@"application/pdf"]) {
        if (! self.pdfView) {
            self.pdfView = [[WebPDF alloc] initWithWebUI:self];
        }
        [self addSubviewAndFill:self.pdfView];
        self.pdfView.hidden = NO;
        NSURLSession* pdf_session = [NSURLSession sharedSession];
        NSURLSessionDataTask* data_session = [pdf_session dataTaskWithURL:self.URL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            [self.pdfView performSelectorOnMainThread:@selector(setDocument:) withObject:[[PDFDocument alloc] initWithData:data] waitUntilDone:YES];
        }];
        [data_session addObserver:self forKeyPath:@"progress.fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
        [data_session resume];
        decisionHandler(WKNavigationResponsePolicyCancel);
        return;
    }
    if (self.pdfView) {
        self.pdfView.hidden = YES;
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (WKWebView *)webView:(WebUI *)webView
createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)navigationAction
        windowFeatures:(WKWindowFeatures *)windowFeatures
{
    // javascript requested window
    Url url = Url(QUrl::fromNSURL(navigationAction.request.URL));
    Webpage_ new_webpage = Webpage_::create(url);
    new_webpage->set_loading_state_direct(Webpage::LoadingStateLoading);
    Global::controller->conscentHttpWebpageUrlChange(new_webpage);
    WebUI* new_webUI = [[WebUI alloc] initWithWebpage:new_webpage frame:self.bounds config:configuration];
    new_webpage->set_associated_frontend_webview_object_direct((__bridge_retained void*)new_webUI);
    if (m_new_request_is_download) {
        m_new_request_is_download = false;
        new_webpage->set_is_for_download_direct(true);
    }
    new_webpage->moveToThread(Global::qCoreApplicationThread);
    Global::controller->newTabByWebpageAsync(0, Controller::TabStateOpen, new_webpage, Controller::WhenCreatedViewNew, Controller::WhenExistsOpenNew);
    return new_webUI;
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

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    BrowserWindowController* windowController = self.window.windowController;
    if ([message.body isEqualToString:@"requestFullscreen"])
    {
        if (! windowController.isFullscreenMode) {
            [windowController enterFullscreenMode];
        }
        if (!(self.window.styleMask & NSWindowStyleMaskFullScreen)) {
            [self.window toggleFullScreen:self];
        }
    }
    if ([message.body isEqualToString:@"exitFullscreen"])
    {
        if (windowController.isFullscreenMode) {
            [windowController exitFullscreenMode];
        }
        if (self.window.styleMask & NSWindowStyleMaskFullScreen) {
            [self.window toggleFullScreen:self];
        }
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSLog(@"Allowing all");
    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
    CFDataRef exceptions = SecTrustCopyExceptions (serverTrust);
    SecTrustSetExceptions (serverTrust, exceptions);
    CFRelease (exceptions);
    completionHandler (NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:serverTrust]);
}

- (void)downloadAsWebArchive
{
    NSString* filename;
    if (self.title && self.title.length > 0) {
        filename = [self.title stringByAppendingString:@".webarchive"];
    } else if (! self.webpage->url().fileName().isEmpty()) {
        filename = (self.webpage->url().fileName() + ".webarchive").toNSString();
    } else {
        filename = (self.webpage->url().full() + ".webarchive").toNSString();
    }
    [[LegacyWebArchiver alloc] initWithFrame:self.frame UrlDownload:self.webpage->url().toNSURL() filename:filename];
}

- (void)downloadAsPDF
{
    QString filename = self.webpage->url().fileName();
    File_ file = Global::controller->createFileDownloadFromUrl(self.webpage->url(), filename);
    Global::controller->startFileDownloadAsync(file);
}
@end

@implementation LegacyWebArchiver
- (instancetype)initWithFrame:(NSRect)frame UrlDownload:(NSURL*)url filename:(NSString*)filename
{
    self = [super initWithFrame:frame];
    self.frameLoadDelegate = self;
    self.shouldUpdateWhileOffscreen = NO;
    self.frameLoadDelegate = self;
    [self.mainFrame loadRequest:[NSURLRequest requestWithURL:url]];
    self.file = Global::controller->createWebArchiveDownloadFromUrl(Url(QUrl::fromNSURL(url)), FileManager::makeFilename(QString::fromNSString(filename)));
    // http blocking not implemented
    Global::controller->conscentHttpFileDownloadAsync(self.file);
    Global::controller->startWebArchiveDownloadAsync(self.file);
    return self;
}

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    WebArchive* archive = frame.dataSource.webArchive;
    NSError* error;
    NSURL* fpath = [NSURL fileURLWithPath:self.file->absoluteFilePath().toNSString()];
    [archive.data writeToURL:fpath options:NSDataWritingAtomic error:&error];
    Global::controller->finishWebArchiveDownloadAsync(self.file);
}
@end
