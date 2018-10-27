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
#import <objc/runtime.h>
#import "CppData.mm.h"
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
            [self performSelectorOnMainThread:@selector(loadUri:) withObject:u waitUntilDone:NO];
        }
    });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_refresh,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(reload) withObject:nil waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_back,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(goBack) withObject:nil waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_forward,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(goForward) withObject:nil waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_stop,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_highlight_all,
                     [=](const QString& keyword) {
                        NSString* txt = keyword.toNSString();
                         [self performSelectorOnMainThread:@selector(highlightAllOccurencesOfString:) withObject:txt waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_clear,
                     [=]() {
                         [self performSelectorOnMainThread:@selector(removeAllHighlights) withObject:nil waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_next_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:NO];
                     });
    QObject::connect(self.webpage.get(),
                     &Webpage::signal_tf_find_scroll_to_prev_highlight,
                     [=](int idx) {
                         NSNumber* n = [NSNumber numberWithInt:idx];
                         [self performSelectorOnMainThread:@selector(scrollToNthHighlight:) withObject:n waitUntilDone:NO];
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
        Global::controller->handleWebpageUrlChangedAsync(self.webpage, QUrl::fromNSURL(url), (__bridge void*)self);
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

- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
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
        NSURLSessionConfiguration* sessionconfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        static WebUIURLSessionDownloadTaskDelegate* sessiondelegate = [[WebUIURLSessionDownloadTaskDelegate alloc] init];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionconfig delegate:sessiondelegate delegateQueue:nil];
        NSURLSessionDownloadTask* task = [session downloadTaskWithURL:url];
        File_ f = Global::controller->downloadFileFromUrlAndRenameBlocking(QString::fromNSString(url.absoluteString), QString::fromNSString(filename));
        [task setFile:f];
        QObject::connect(f.get(), &File::signal_tf_download_resume,[=]() {
            [task performSelectorOnMainThread:@selector(resume) withObject:nil waitUntilDone:NO];
        });
        QObject::connect(f.get(), &File::signal_tf_download_stop,[=]() {
            [task performSelectorOnMainThread:@selector(cancelByProducingResumeData:) withObject:(^(NSData * _Nullable resumeData) {
                // not implemented
            }) waitUntilDone:NO];
        });
        if (f->downloading()) {
            [task resume];
        }
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

@implementation WebUIURLSessionDownloadTaskDelegate
// called when download restarts
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
//    File_ f = Global::controller->downloadFileFromBlocking(QString::fromNSString(downloadTask.response.URL.absoluteString));
    
}
// called when receiving new data during download
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    File_ f = downloadTask.file;
    f->set_size_bytes_addition_async(bytesWritten);
    f->set_size_bytes_downloaded_async(totalBytesWritten);
    f->set_size_bytes_expected_async(totalBytesExpectedToWrite);
    f->set_percentage_async((float)totalBytesWritten / (float)totalBytesExpectedToWrite);
}
// called when download finishes
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    File_ f = downloadTask.file;
    f->setFile(QString::fromNSString(location.path));
    Global::controller->handleFileDownloadFinishedBlocking(f);
}
@end

@implementation NSURLSessionTask(Pointer)
- (void)setFile:(File_)file {
    id item = [QSharedPointerWrapper wrap:file.staticCast<QObject>()];
    objc_setAssociatedObject(self, @selector(file), item, OBJC_ASSOCIATION_RETAIN);
}
- (File_)file {
    QSharedPointerWrapper* item = objc_getAssociatedObject(self, @selector(file));
    return item.ptr.staticCast<File>();
}
@end

