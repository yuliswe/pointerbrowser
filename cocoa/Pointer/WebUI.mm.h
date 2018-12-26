//
//  WebUI.h
//  Pointer
//
//  Created by Yu Li on 2018-08-01.
//  Copyright © 2018 Yu Li. All rights reserved.
//

#import <WebKit/WebKit.h>
#include <docviewer/docviewer.h>
#include "TabView.mm.h"
#import "ErrorPage.h"

@class TabItemView;

@interface LegacyWebView : WebView<WebFrameLoadDelegate>
@end

@interface WebUI : WKWebView<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
{
    bool m_new_request_is_download;
    id m_wkwebview_menu_target_for_open_in_new_window;
    SEL m_wkwebview_menu_action_for_open_in_new_window;
    NSMenuItem* m_wkwebview_menu_open_in_new_window_clone;
}
@property ErrorPageViewController* error_page_view_controller;
@property BOOL is_pesudo_url;
@property Webpage_ webpage;
@property LegacyWebView* legacyWebView;
@property BOOL m_redirected_from_error;

- (instancetype)initWithWebpage:(Webpage_)webpage
                          frame:(NSRect)frame
                         config:(WKWebViewConfiguration*)config;

- (void)loadUrlString:(NSString*)url;
- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;
- (void)disconnect;
- (void)print;
- (void)downloadAsWebArchive;
- (void)downloadAsPDF;
- (void)exitVideoFullscreen;
@end

