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

@interface WebUI : WKWebView<WKNavigationDelegate,WKUIDelegate>
{
    Webpage_ m_webpage;
    NSURL* m_erroring_url;
    bool m_redirected_from_error;
    ErrorPageViewController* m_error_page_view_controller;
}

@property Webpage_ webpage;

- (instancetype)initWithWebpage:(Webpage_)webpage
                          frame:(NSRect)frame
                         config:(WKWebViewConfiguration*)config;
- (void)loadUri:(NSString*)url;

- (NSInteger)highlightAllOccurencesOfString:(NSString*)str;
- (void)removeAllHighlights;

@end

